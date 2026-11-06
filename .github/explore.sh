pacman -Q squashfs-tools xz
mkdir -p /tmp/src && cp -a /usr/lib /usr/bin /usr/share/locale /tmp/src/ 2>/dev/null; du -sh /tmp/src
for opts in "-comp xz -Xbcj x86,arm64 -b 1M -Xdict-size 1M" "-comp xz -Xbcj x86 -b 1M -Xdict-size 1M" "-comp xz -b 1M" "-comp zstd -Xcompression-level 19 -b 1M" "-comp zstd -Xcompression-level 15 -b 1M"; do
  rm -f /tmp/t.sfs
  start=$(date +%s)
  if mksquashfs /tmp/src /tmp/t.sfs $opts -noappend -no-progress >/tmp/log 2>&1; then
    echo "OK   $(du -m /tmp/t.sfs | cut -f1) MiB  $(( $(date +%s)-start ))s  [$opts]"
  else
    echo "FAIL [$opts]: $(grep -i error /tmp/log | head -2)"
  fi
done
