#!/usr/bin/env bash
# Повний тест установки в QEMU:
#   1) жива система з параметром ember.autotest=1 встановлює Ember OS на віртуальний диск;
#   2) завантаження з цього диска, скриншоти GRUB / заставки / робочого столу.
# Usage: tests/install-test.sh ISO OUTDIR
set -uo pipefail
ISO="${1:?ISO}"; OUT="${2:-screenshots}"
mkdir -p "$OUT"
W=$(mktemp -d)
DISK="$W/disk.qcow2"
qemu-img create -q -f qcow2 "$DISK" 30G

ACCEL=(-accel tcg); SCALE=4
[[ -w /dev/kvm ]] && { ACCEL=(-enable-kvm -cpu host); SCALE=1; }

# Ядро та initramfs з ISO, щоб передати свій параметр ember.autotest=1
bsdtar -xf "$ISO" -C "$W" arch/boot/x86_64/vmlinuz-linux arch/boot/x86_64/initramfs-linux.img
LABEL=$(blkid -o value -s LABEL "$ISO")
echo "ISO label: $LABEL"

# Свіжі скрипти з репозиторію на маленькому диску EMBERTEST (підміняють вбудовані)
TESTIMG="$W/embertest.img"
truncate -s 16M "$TESTIMG"
mkfs.vfat -n EMBERTEST "$TESTIMG" >/dev/null
for f in profile/airootfs/usr/local/bin/ember-autotest profile/airootfs/usr/local/bin/ember-postinstall \
         profile/airootfs/usr/local/bin/ember-copy-kernel profile/airootfs/usr/local/bin/ember-find-sfs \
         profile/airootfs/usr/local/bin/ember-setup-apps profile/airootfs/usr/local/bin/ember-drivers \
         profile/airootfs/usr/local/bin/ember-install-hydra profile/airootfs/usr/local/bin/ember-drivers-boot; do
  mcopy -i "$TESTIMG" "$f" ::/
done
for c in profile/airootfs/etc/calamares/modules/*.conf; do mcopy -i "$TESTIMG" "$c" ::/; done

echo "=== Phase 1: automated install ==="
timeout $((40 * 60)) qemu-system-x86_64 "${ACCEL[@]}" -m 4096 -smp 2 \
  -kernel "$W/arch/boot/x86_64/vmlinuz-linux" -initrd "$W/arch/boot/x86_64/initramfs-linux.img" \
  -append "archisobasedir=arch archisolabel=$LABEL ember.autotest=1 console=tty0 console=ttyS0,115200" \
  -drive file="$ISO",media=cdrom,readonly=on \
  -device virtio-scsi-pci,id=scsi0 \
  -drive file="$DISK",if=none,id=target,format=qcow2 \
  -device scsi-hd,drive=target,bus=scsi0.0,rotation_rate=1 \
  -drive file="$TESTIMG",if=virtio,format=raw \
  -nic user,model=virtio-net-pci \
  -vga virtio -display none -serial file:"$OUT/install-serial.log" -no-reboot
grep -a "EMBER-AUTOTEST" "$OUT/install-serial.log" | tee "$OUT/install-result.txt"
if ! grep -aq "EMBER-AUTOTEST: OK" "$OUT/install-serial.log"; then
  echo "::error::Automated install FAILED (see install-serial.log)"
  exit 1
fi

echo "=== Phase 2: boot the installed system ==="
MON=$W/mon.sock
qemu-system-x86_64 "${ACCEL[@]}" -m 4096 -smp 2 \
  -device virtio-scsi-pci,id=scsi0 \
  -drive file="$DISK",if=none,id=target,format=qcow2 \
  -device scsi-hd,drive=target,bus=scsi0.0,rotation_rate=1,bootindex=0 \
  -nic user,model=virtio-net-pci \
  -vga virtio -display none -serial file:"$OUT/installed-serial.log" \
  -monitor unix:"$MON",server,nowait &
QPID=$!
shot() {
  sleep $(( $2 * SCALE ))
  kill -0 "$QPID" 2>/dev/null || { echo "QEMU exited early"; return 1; }
  echo "screendump $W/$1.ppm" | socat - "UNIX-CONNECT:$MON" >/dev/null; sleep 1
  convert "$W/$1.ppm" "$OUT/$1.png" && echo "screenshot: $1"
}
st=0
shot 10-installed-grub 3     || st=1
shot 11-installed-boot 8     || st=1
shot 12-installed-desktop 50 || st=1
shot 13-installed-later 30   || st=1
# Ждём, пока установленная система сама докачает Steam / Wine / Hydra (до 25 мин)
for i in $(seq 150); do
  grep -aq "EMBER-INSTALLED: apps " "$OUT/installed-serial.log" && break
  sleep 10
done
sleep 5
shot 14-installed-apps 1 || true
waitmark() { for i in $(seq "$2"); do grep -aq "EMBER-INSTALLED: $1" "$OUT/installed-serial.log" && return 0; sleep 2; done; return 1; }
waitmark "launcher shown" 60 && { sleep 3; shot 15-launcher 0 || true; }
waitmark "antivirus shown" 240 && { sleep 3; shot 16-antivirus 0 || true; }
waitmark "calc shown" 120 && { sleep 3; shot 17-calculator 0 || true; }
waitmark "office shown" 120 && { sleep 3; shot 18-office 0 || true; }
waitmark "slides shown" 180 && { sleep 3; shot 19-slides 0 || true; }
sleep 10
echo quit | socat - "UNIX-CONNECT:$MON" >/dev/null 2>&1 || true
wait "$QPID" 2>/dev/null
grep -a "EMBER-INSTALLED" "$OUT/installed-serial.log" | tee -a "$OUT/install-result.txt"
for need in "multi-user OK" "Hyprland running" "apps done" "hydra installed"; do
  grep -aq "EMBER-INSTALLED: $need" "$OUT/installed-serial.log" \
    || { echo "::error::Installed system check failed: $need"; st=1; }
done
exit $st
