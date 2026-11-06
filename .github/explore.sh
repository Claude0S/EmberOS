hyprctl --help 2>&1 | head -60
echo "=== hyprctl dispatch help"; hyprctl dispatch 2>&1 | head
echo "=== files"; find /usr/share -iname '*hypr*' -maxdepth 3 | head -30
echo "=== hypridle example"; cat /usr/share/hypr/hypridle.conf 2>/dev/null || find / -name 'hypridle.conf' -not -path '/proc/*' 2>/dev/null
echo "=== dpms strings"; strings /usr/bin/Hyprland | grep -iE 'dpms' | head -20
echo "=== legacy dispatch strings"; strings /usr/bin/Hyprland | grep -iE 'legacy|hyprlang dispatch|dispatch.*lua' | head -20
echo "=== wayland sessions"; ls /usr/share/wayland-sessions; cat /usr/share/wayland-sessions/*.desktop
