R=/usr/share/archiso/configs/releng
cat $R/profiledef.sh
echo "=== RELENG PKGS + sizes"
pacman -Sy >/dev/null
for p in $(cat $R/packages.x86_64) $(grep -vE '^\s*(#|$)' profile/packages.x86_64); do
  s=$(pacman -Si "$p" 2>/dev/null | awk -F': ' '/^Download Size/{print $2; exit}'); echo "$s $p"
done | sort -h -k1,1 | awk '{print}' | tail -60
echo "=== bootloader entries"; ls $R/efiboot/loader/entries $R/syslinux $R/grub 2>/dev/null
