set -x
pacman -S --noconfirm --needed sudo python curl gtk-update-icon-cache >/dev/null 2>&1 || pacman -S --noconfirm --needed sudo python curl >/dev/null
useradd -m tester && echo "tester ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/t
# simulate an OLD install: skel from build-19 era = old hyprland.lua with hyprpaper, no theme files
mkdir -p /home/tester/.config/hypr && echo 'hl.on("hyprland.start", function() hl.exec_cmd("hyprpaper") end)' > /home/tester/.config/hypr/hyprland.lua
echo '-- my stuff' > /home/tester/.config/hypr/user.lua
chown -R tester: /home/tester
set +x
su - tester -c 'EMBER_BRANCH=ci-lint bash -c "curl -fsSL https://raw.githubusercontent.com/Claude0S/EmberOS/ci-lint/profile/airootfs/usr/local/bin/ember-selfupdate | EMBER_BRANCH=ci-lint bash"' 2>&1 | tail -15
echo "=== after"
ls /usr/local/bin/ | grep ember | tr '\n' ' '; echo
su - tester -c 'grep -c theme ~/.config/hypr/hyprland.lua; cat ~/.config/hypr/user.lua; ls ~/.config/hypr ~/.config/waybar ~/.config/ember; ember-theme set night; ember-theme mascot ember; ember-theme status; head -3 ~/.config/waybar/colors.css'
