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

echo "=== Phase 1: automated install ==="
timeout $((40 * 60)) qemu-system-x86_64 "${ACCEL[@]}" -m 4096 -smp 2 \
  -kernel "$W/arch/boot/x86_64/vmlinuz-linux" -initrd "$W/arch/boot/x86_64/initramfs-linux.img" \
  -append "archisobasedir=arch archisolabel=$LABEL ember.autotest=1 console=tty0 console=ttyS0,115200" \
  -drive file="$ISO",media=cdrom,readonly=on \
  -drive file="$DISK",if=virtio,format=qcow2 \
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
  -drive file="$DISK",if=virtio,format=qcow2 -boot c \
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
echo quit | socat - "UNIX-CONNECT:$MON" >/dev/null 2>&1 || true
wait "$QPID" 2>/dev/null
exit $st
