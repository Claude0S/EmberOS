pacman -Q hyprpaper nwg-dock-hyprland
echo "=== hyprpaper files"; pacman -Ql hyprpaper | grep -vE '/$' | head -20
echo "=== hyprpaper help"; hyprpaper --help 2>&1 | head -30
for f in $(pacman -Ql hyprpaper | awk '{print $2}' | grep -E '\.conf$|example'); do echo "=== $f"; cat $f; done
echo "=== nwg-dock help"; nwg-dock-hyprland -h 2>&1 | head -60
echo "=== hyprland misc keys"; strings /usr/bin/Hyprland | grep -E '^misc:(disable_|force_default)' | sort -u
