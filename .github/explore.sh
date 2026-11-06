printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
pacman -Sy >/dev/null
for p in steam wine wine-mono wine-gecko winetricks umu-launcher lutris discord telegram-desktop vlc obs-studio libreoffice-fresh code gimp krita prismlauncher flatpak fuse2 heroic-games-launcher mangohud gamemode lib32-gamemode qbittorrent spotify-launcher chromium audacity kdenlive blender godot inkscape zram-generator tlp thermald vulkan-intel lib32-vulkan-intel vulkan-radeon lib32-vulkan-radeon nvidia-open nvidia-utils lib32-nvidia-utils xf86-video-intel intel-media-driver libva-intel-driver mesa-utils vulkan-tools hwdata pciutils usbutils sof-firmware alsa-ucm-conf calamares archlinux-keyring os-prober grub efibootmgr mkinitcpio-utils python-gobject webkit2gtk-4.1 gtk4 libadwaita kvantum; do
  r=$(pacman -Si "$p" 2>/dev/null | awk -F': ' '/^Repository/{print $2; exit}')
  printf '%-24s %s\n' "$p" "${r:-MISSING}"
done
