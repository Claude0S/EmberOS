set -x
useradd -m t
cp -r profile/airootfs/etc/skel/. /home/t/
cp profile/airootfs/usr/share/ember/little/mode.lua /tmp/little.lua
chown -R t: /home/t
cat > /tmp/t.sh <<'EOS'
export XDG_RUNTIME_DIR=$(mktemp -d)
C=$HOME/.config/hypr/hyprland.lua
echo "=== VERIFY FULL ==="; Hyprland --verify-config -c "$C" 2>&1 | grep -v DEBUG
cp $HOME/.config/hypr/mode.lua /tmp/full.lua; cp /tmp/little.lua $HOME/.config/hypr/mode.lua
echo "=== VERIFY LITTLE ==="; Hyprland --verify-config -c "$C" 2>&1 | grep -v DEBUG
cp /tmp/full.lua $HOME/.config/hypr/mode.lua
echo "=== HEADLESS RUN ==="
HYPRLAND_HEADLESS_ONLY=1 AQ_BACKENDS=headless Hyprland > /tmp/hl.log 2>&1 &
sleep 10
hyprctl version | head -2
hyprctl monitors | head -5
for c in 'togglespecialworkspace shell' 'hl.dsp.workspace.toggle_special("shell")' 'dpms off' 'hl.dsp.dpms({ action = "off" })' 'hl.dsp.dpms("off")' 'hl.dsp.dpms({ action = "on" })' 'workspace e+1' 'hl.dsp.focus({ workspace = "e+1" })' 'hl.dsp.focus({ workspace = 2 })' 'hl.dsp.exec_cmd("true")' 'hl.dsp.window.fullscreen()' 'hl.dsp.reload_config()'; do
  echo ">> dispatch [$c]"; hyprctl dispatch "$c" 2>&1 | head -3
done
echo ">> hyprctl activeworkspace"; hyprctl activeworkspace | head -2
echo ">> clients -j"; hyprctl clients -j | head -5
echo ">> layers"; hyprctl layers | head
echo ">> configerrors"; hyprctl configerrors
echo "=== HL LOG (errors) ==="; grep -iE "err|warn|lua" /tmp/hl.log | head -40
EOS
su t -c 'bash /tmp/t.sh'
