-- Hyprland 0.55+ configuration.
-- Validate without starting a session:
--   Hyprland --verify-config -c ~/.config/hypr/hyprland.lua

local home = os.getenv("HOME")
local runtimeDir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "pgrep -x wofi >/dev/null || wofi --show drun --allow-images -a --prompt 'Search'"
local mainMod = "SUPER"

-- Session-only state written by the power and refresh helpers. Lua-configured
-- Hyprland updates dynamically through reloads rather than `hyprctl keyword`.
local function runtimePreference(name, allowed, fallback)
    local file = io.open(runtimeDir .. "/" .. name, "r")
    if file == nil then
        return fallback
    end

    local value = file:read("*l")
    file:close()
    if value ~= nil and allowed[value] then
        return value
    end
    return fallback
end

local internalRefreshRate = runtimePreference("hypr-eDP-1-refresh-rate", {
    ["60"] = true,
    ["165"] = true,
}, "165")
local desktopPowerProfile = runtimePreference("hypr-power-profile", {
    ["power-saver"] = true,
    ["balanced"] = true,
    ["performance"] = true,
}, "balanced")
local compositorEffectsEnabled = desktopPowerProfile ~= "power-saver"

----------------
-- Monitors
----------------

hl.monitor({
    output = "",
    mode = "2560x1600@" .. internalRefreshRate,
    position = "auto",
    scale = 1.6,
})

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@143.98",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@165",
    position = "1920x0",
    scale = 1,
    transform = 1,
})

----------------
-- Autostart
----------------

hl.on("hyprland.start", function()
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("eww open osd")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("mako")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

----------------
-- Appearance
----------------

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = {
                colors = {"rgba(ffffffff)", "rgba(ffffff20)"},
                angle = 45,
            },
            inactive_border = {
                colors = {"rgba(ffffff10)", "rgba(ffffff20)"},
                angle = 45,
            },
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 8,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = compositorEffectsEnabled,
            range = 2,
            render_power = 3,
            color = "rgba(2a2a2aee)",
        },
        blur = {
            enabled = compositorEffectsEnabled,
            size = 2,
            passes = 4,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = compositorEffectsEnabled,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

hl.curve("easeOutQuint", {
    type = "bezier",
    points = {{0.23, 1}, {0.32, 1}},
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = {{0.65, 0.05}, {0.36, 1}},
})
hl.curve("linear", {
    type = "bezier",
    points = {{0, 0}, {1, 1}},
})
hl.curve("almostLinear", {
    type = "bezier",
    points = {{0.5, 0.5}, {0.75, 1}},
})
hl.curve("quick", {
    type = "bezier",
    points = {{0.15, 0}, {0.1, 1}},
})

hl.animation({leaf = "global", enabled = true, speed = 10, bezier = "default"})
hl.animation({leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint"})
hl.animation({leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint"})
hl.animation({leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%"})
hl.animation({leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%"})
hl.animation({leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear"})
hl.animation({leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear"})
hl.animation({leaf = "fade", enabled = true, speed = 3.03, bezier = "quick"})
hl.animation({leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint"})
hl.animation({leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade"})
hl.animation({leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade"})
hl.animation({leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear"})
hl.animation({leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"})
hl.animation({leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide"})
hl.animation({leaf = "workspacesIn", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide"})
hl.animation({leaf = "workspacesOut", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide"})

hl.layer_rule({
    name = "waybar-effects",
    match = {namespace = "waybar"},
    blur = true,
    blur_popups = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "wofi-effects",
    match = {namespace = "wofi"},
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name = "notification-effects",
    match = {namespace = "notifications"},
    blur = true,
    ignore_alpha = 0,
})

----------------
-- Input
----------------

hl.config({
    input = {
        kb_layout = "se",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0.1,
        touchpad = {
            scroll_factor = 0.4,
            natural_scroll = true,
        },
    },

    gestures = {
        workspace_swipe_invert = true,
        workspace_swipe_distance = 700,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = 1,
})

----------------
-- Key bindings
----------------

hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd(home .. "/.config/hypr/lockin.sh"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({action = "toggle"}))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.layout("togglesplit"))

local directions = {
    h = "l",
    l = "r",
    k = "u",
    j = "d",
}

for key, direction in pairs(directions) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({direction = direction}))
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({workspace = i}))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({workspace = "special:magic"}))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({workspace = "e+1"}))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({workspace = "e-1"}))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {mouse = true})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {mouse = true})

local resizeBinds = {
    h = {-40, 0},
    l = {40, 0},
    k = {0, -40},
    j = {0, 40},
}

for key, delta in pairs(resizeBinds) do
    hl.bind(
        mainMod .. " + ALT + " .. key,
        hl.dsp.window.resize({x = delta[1], y = delta[2], relative = true}),
        {repeating = true}
    )
end

local moveBinds = {
    h = {-50, 0, "l"},
    l = {50, 0, "r"},
    k = {0, -50, "u"},
    j = {0, 50, "d"},
}

for key, movement in pairs(moveBinds) do
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.swap({direction = movement[3]}))
    hl.bind(
        mainMod .. " + CTRL + " .. key,
        hl.dsp.window.move({x = movement[1], y = movement[2], relative = true}),
        {repeating = true}
    )
end

-- brightnessctl automatically selects the backlight device. Do not hard-code
-- intel_backlight: this machine exposes amdgpu_bl1 after the reinstall.
-- The OSD reads the resulting value, so it stays in sync with these exact steps.
local osd = "bash " .. home .. "/.config/eww/scripts/osd.sh"
hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -n2 set 10%- && " .. osd .. " brightness"),
    {locked = true, repeating = true}
)
hl.bind(
    "CTRL + XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -n2 set 2%- && " .. osd .. " brightness"),
    {locked = true, repeating = true}
)
hl.bind(
    "SHIFT + XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -n2 set 1% && " .. osd .. " brightness"),
    {locked = true}
)
hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -n2 set 10%+ && " .. osd .. " brightness"),
    {locked = true, repeating = true}
)
hl.bind(
    "CTRL + XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -n2 set 2%+ && " .. osd .. " brightness"),
    {locked = true, repeating = true}
)
hl.bind(
    "SHIFT + XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -n2 set 100% && " .. osd .. " brightness"),
    {locked = true}
)

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && " .. osd .. " volume"), {locked = true, repeating = true})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " .. osd .. " volume"), {locked = true, repeating = true})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " .. osd .. " volume"), {locked = true})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {locked = true})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {locked = true})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {locked = true})

hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd(home .. "/.config/hypr/screenshot-copy.sh"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(home .. "/.config/hypr/screenshot-ocr.sh"))
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd(home .. "/.config/hypr/powerprofiles-toggle.sh"))
-- Linux 6.9+ exposes the Lenovo Fn+R refresh shortcut as this keysym.
-- The helper cycles the panel's 60 Hz and 165 Hz modes.
hl.bind("XF86RefreshRateToggle", hl.dsp.exec_cmd(home .. "/.config/hypr/refresh-rate-toggle.sh"), {locked = true})
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(home .. "/.config/hypr/refresh-rate-toggle.sh"))
hl.bind(
    mainMod .. " + CTRL + B",
    hl.dsp.exec_cmd("bluetoothctl info 3C:B0:ED:D1:E7:8D | grep -q 'Connected: yes' && bluetoothctl disconnect 3C:B0:ED:D1:E7:8D || bluetoothctl connect 3C:B0:ED:D1:E7:8D")
)
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload && notify-send 'Hyprland config reloaded'"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("kitty --class fzf-dropper -e " .. home .. "/dotfiles/scripts/fzf-copy.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty --class fzf-dropper -e " .. home .. "/dotfiles/scripts/fzf-explorer.sh"))

----------------
-- Window rules
----------------

hl.window_rule({
    name = "single-tiled-window-no-border",
    match = {float = false, workspace = "w[tv1]"},
    border_size = 0,
})

hl.window_rule({
    name = "fullscreen-workspace-no-border",
    match = {float = false, workspace = "f[1]"},
    border_size = 0,
})

hl.window_rule({
    name = "float-dolphin",
    match = {class = ".*[Dd]olphin.*"},
    float = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = {class = ".*"},
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "fzf-dropper",
    match = {class = "^(fzf-dropper)$"},
    float = true,
    size = {800, 250},
    move = {"cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)"},
})
