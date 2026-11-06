pacman -S --noconfirm --needed git base-devel >/dev/null 2>&1
printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf; pacman -Sy >/dev/null
cd /tmp && git clone -q https://aur.archlinux.org/calamares.git && cd calamares
echo "=== PKGBUILD"; cat PKGBUILD
source PKGBUILD
echo "=== DEP CHECK"
for d in "${depends[@]}" "${makedepends[@]}"; do d=${d%%[<>=]*}; r=$(pacman -Si "$d" 2>/dev/null | awk -F': ' '/^Repository/{print $2; exit}'); [ -z "$r" ] && r=$(pacman -Sp --print-format %r "$d" 2>/dev/null | tail -1); echo "$d ${r:-AUR?}"; done
echo "=== DRIVER PKGS"
for p in vulkan-nouveau lib32-vulkan-nouveau switcheroo-control nvidia-settings egl-wayland alsa-firmware broadcom-wl spice-vdagent open-vm-tools qemu-guest-agent amd-ucode intel-ucode thermald power-profiles-daemon ntfs-3g dosfstools exfatprogs; do r=$(pacman -Si "$p" 2>/dev/null | awk -F': ' '/^Repository/{print $2; exit}'); echo "$p ${r:-MISSING}"; done
echo "=== SIZE of calamares deps (repo)"
pacman -Sp --print-format '%s %n' $(for d in "${depends[@]}"; do d=${d%%[<>=]*}; pacman -Si $d >/dev/null 2>&1 && echo $d; done) 2>/dev/null | awk '{s+=$1} END {printf "%.0f MiB\n", s/1048576}'
