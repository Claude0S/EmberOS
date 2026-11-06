R=/usr/share/archiso/configs/releng
printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
pacman -Sy >/dev/null
P=$( (cat $R/packages.x86_64; grep -vE '^\s*(#|$)' profile/packages.x86_64) | sort -u)
echo "=== TOTAL resolved (download bytes, top 45)"
pacman -Sp --print-format '%s %n' $P 2>/dev/null | sort -n | tail -45 | awk '{printf "%8.1f MiB  %s\n", $1/1048576, $2}'
pacman -Sp --print-format '%s' $P 2>/dev/null | awk '{s+=$1} END {printf "TOTAL download: %.0f MiB\n", s/1048576}'
echo "=== extras (steam wine etc)"
pacman -Sp --print-format '%s %n' $P steam wine wine-mono winetricks umu-launcher lib32-mesa lib32-vulkan-intel vulkan-intel 2>/dev/null | sort -n > /tmp/all
pacman -Sp --print-format '%s %n' $P 2>/dev/null | sort -n > /tmp/base
comm -13 <(awk '{print $2}' /tmp/base | sort) <(awk '{print $2}' /tmp/all | sort) > /tmp/extra
grep -wFf /tmp/extra /tmp/all | awk '{s+=$1} END {printf "steam+wine extra: %.0f MiB\n", s/1048576}'
