#!/usr/bin/env bash
# Boots the freshly built ISO in QEMU and takes screenshots,
# so every build is visually checked before anyone downloads it.
# Usage: tests/qemu-boot.sh path/to/emberos.iso [outdir]
set -euo pipefail

ISO="${1:?usage: qemu-boot.sh ISO [outdir]}"
OUTDIR="${2:-screenshots}"
mkdir -p "$OUTDIR"
MON=/tmp/ember-qemu.sock
rm -f "$MON"

ACCEL=(-accel tcg)
SCALE=4   # TCG is slow: wait longer
if [[ -w /dev/kvm ]]; then
  ACCEL=(-enable-kvm -cpu host)
  SCALE=1
  echo "KVM available"
else
  echo "KVM not available, using TCG (slow)"
fi

qemu-system-x86_64 "${ACCEL[@]}" -m 4096 -smp 2 \
  -cdrom "$ISO" -boot d \
  -vga virtio -display none \
  -serial file:"$OUTDIR/serial.log" \
  -monitor unix:"$MON",server,nowait \
  -nic user,model=virtio-net-pci &
QPID=$!

shot() { # name delay_seconds
  sleep $(( $2 * SCALE ))
  if ! kill -0 "$QPID" 2>/dev/null; then echo "QEMU exited early"; return 1; fi
  echo "screendump /tmp/$1.ppm" | socat - "UNIX-CONNECT:$MON" >/dev/null
  sleep 1
  convert "/tmp/$1.ppm" "$OUTDIR/$1.png"
  echo "screenshot: $OUTDIR/$1.png"
}

status=0
shot 01-bootmenu 5      || status=1
shot 02-booting 25      || status=1
shot 03-desktop 60      || status=1
shot 04-desktop-later 30 || status=1

echo "quit" | socat - "UNIX-CONNECT:$MON" >/dev/null 2>&1 || true
wait "$QPID" 2>/dev/null || true
exit $status
