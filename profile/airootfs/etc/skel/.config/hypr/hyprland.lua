-- ───────────────────────────────────────────────
--  Ember OS — Hyprland (Lua, Hyprland 0.55+)
--  Свои правки удобнее класть в ~/.config/hypr/user.lua
-- ───────────────────────────────────────────────

-- Монитор: родное разрешение и частота, автоматически
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local terminal = "kitty"
local files    = "thunar"
local browser  = "firefox"
local menu     = "fuzzel"
local mod      = "SUPER"

-- ─── Автозапуск ───
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd('nwg-dock-hyprland -x -i 42 -mb 10 -c "fuzzel"')
    hl.exec_cmd("/usr/local/bin/ember-autostart-widgets")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("/usr/local/bin/ember-firstrun")
end)

-- Мова інтерфейсу (/lang uk | en)
pcall(function()
    local f = io.open(os.getenv("HOME") .. "/.config/ember/lang", "r")
    if f then
        local l = f:read("*l"); f:close()
        if l == "en" then hl.env("LANG", "en_US.UTF-8")
        elseif l == "uk" then hl.env("LANG", "uk_UA.UTF-8") end
    end
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "Adwaita:dark")

-- ─── Внешний вид ───
hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 14,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(e8875aee)", "rgba(f2c37aee)" }, angle = 45 },
            inactive_border = "rgba(52304966)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 14,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 0.94,
        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            color = 0xaa0a060c,
        },
        blur = {
            enabled = true,
            size = 7,
            passes = 2,
            vibrancy = 0.2,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = 0xff1a1320,
        focus_on_activate = true,
    },

    input = {
        kb_layout = "us,ua",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
    },
})

-- ─── Анимации ───
hl.curve("ember", { type = "bezier", points = { {0.22, 1},  {0.36, 1} } })
hl.curve("soft",  { type = "bezier", points = { {0.4, 0},   {0.2, 1} } })
hl.curve("pop",   { type = "spring", mass = 1, stiffness = 230, damping = 22 })

hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4.5, spring = "pop",    style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3.5, bezier = "soft",   style = "popin 85%" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 4,   bezier = "ember" })
hl.animation({ leaf = "border",           enabled = true, speed = 8,   bezier = "soft" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 40,  bezier = "soft",   style = "loop" })
hl.animation({ leaf = "fade",             enabled = true, speed = 5,   bezier = "ember" })
hl.animation({ leaf = "layers",           enabled = true, speed = 4,   bezier = "ember",  style = "fade" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5,   bezier = "ember",  style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5,   bezier = "ember",  style = "slidevert" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ─── Правила окон ───
hl.window_rule({
    name  = "ember-float-tools",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager)$" },
    float = true,
})
hl.window_rule({
    name  = "ember-pip",
    match = { title = "^(Picture-in-Picture|Картинка в картинке)$" },
    float = true,
    pin   = true,
})
-- Командная строка Ember (Win+Enter) — на своём «специальном» рабочем столе
hl.window_rule({
    name       = "ember-shell",
    match      = { class = "^(ember-shell)$" },
    workspace  = "special:shell silent",
    fullscreen = true,
})

for _, ns in ipairs({ "waybar", "launcher", "swaync-control-center", "nwg-dock", "ember-widget" }) do
    hl.layer_rule({ name = "ember-blur-" .. ns, match = { namespace = "^" .. ns .. "$" }, blur = true, ignore_alpha = 0.1 })
end

-- ─── Клавиши ───
local function bind(keys, cmd, opts) hl.bind(keys, hl.dsp.exec_cmd(cmd), opts) end

bind(mod .. " + RETURN", "/usr/local/bin/ember-toggle-shell")
bind(mod .. " + T", terminal)
bind(mod .. " + E", files)
bind(mod .. " + B", browser)
bind(mod .. " + D", menu)
bind(mod .. " + SPACE", menu)
bind(mod .. " + L", "hyprlock")
bind(mod .. " + N", "swaync-client -t -sw")
bind(mod .. " + SHIFT + E", "/usr/local/bin/ember-power")
bind(mod .. " + SHIFT + V", "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy")
bind("Print", 'grim -g "$(slurp)" - | wl-copy && notify-send "Ember OS" "📸 Знімок скопійовано · Screenshot copied"')
bind("SHIFT + Print", 'mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%F-%H%M%S).png && notify-send "Ember OS" "📸 Знімок збережено · Screenshot saved"')

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Мультимедиа-клавиши ноутбука
local media = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume",  "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+", media)
bind("XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", media)
bind("XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", media)
bind("XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", media)
bind("XF86MonBrightnessUp",   "brightnessctl -e4 -n2 set 5%+", media)
bind("XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-", media)
bind("XF86AudioPlay",  "playerctl play-pause", { locked = true })
bind("XF86AudioPause", "playerctl play-pause", { locked = true })
bind("XF86AudioNext",  "playerctl next",       { locked = true })
bind("XF86AudioPrev",  "playerctl previous",   { locked = true })

-- Режим full / little (/little и /full меняют файл mode.lua)
pcall(require, "mode")
-- Личные настройки пользователя (не перезаписываются обновлениями)
pcall(require, "user")
