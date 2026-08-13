-- Ben Bazzite Hyprland desktop.
-- This image-owned fallback is copied to ~/.config/hypr/hyprland.lua on first use.

local terminal = "ghostty"
local launcher = "fuzzel"
local wallpaper = "/usr/share/backgrounds/ben-bazzite/aurora-glass.png"

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

-- Bazzite owns the NVIDIA driver, kernel module, modesetting, and gaming stack.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Adwaita's built-in dark variant works for both classic GTK applications and
-- modern GTK 4/libadwaita applications such as Files and Zenity.
hl.env("GTK_THEME", "Adwaita:dark")
-- Let Qt applications inherit the same GTK colors instead of falling back to
-- a bright Fusion theme.
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

hl.config({
    general = {
        layout = "dwindle",
        border_size = 2,
        gaps_in = 5,
        gaps_out = 9,
        gaps_workspaces = 12,
        resize_on_border = true,
        allow_tearing = false,
        ["col.active_border"] = {
            colors = { "#6ee7faff", "#9b7bffff", "#ff7a90ff" },
            angle = 45,
        },
        ["col.inactive_border"] = "#263353cc",
    },
    decoration = {
        rounding = 12,
        rounding_power = 3.0,
        active_opacity = 1.0,
        inactive_opacity = 0.96,
        dim_special = 0.35,
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            new_optimizations = true,
            xray = true,
            vibrancy = 0.18,
            popups = true,
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            color = "#050713aa",
            offset = { 0, 6 },
        },
        glow = {
            enabled = true,
            range = 8,
            render_power = 3,
            color = "#6ee7fa26",
        },
    },
    animations = {
        enabled = true,
        workspace_wraparound = true,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0.0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
    },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        background_color = "#070b18",
        close_special_on_empty = true,
        initial_workspace_tracking = 1,
    },
})

hl.curve("benEase", {
    type = "bezier",
    points = { { 0.22, 1.0 }, { 0.36, 1.0 } },
})
hl.curve("benSpring", {
    type = "spring",
    mass = 1.0,
    stiffness = 110.0,
    dampening = 16.0,
})
hl.animation({ leaf = "windows", enabled = true, speed = 4.0, spring = "benSpring", style = "popin 88%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.0, bezier = "benEase", style = "popin 92%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.0, bezier = "benEase" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "benEase", style = "slidefade 18%" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.5, bezier = "benEase", style = "fade" })

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true })

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/libexec/ben-bazzite/session-start")
    hl.exec_cmd("/usr/libexec/ben-bazzite/dark-theme")
    hl.exec_cmd("hyprpaper -c /usr/share/hypr/hyprpaper.conf")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako --config /etc/xdg/mako/config")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("hypridle -c /usr/share/hypr/hypridle.conf")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
end)

-- Apps and session controls.
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + E", hl.dsp.exec_cmd("env GTK_THEME=Adwaita:dark nautilus --new-window"))
hl.bind("SUPER + F1", hl.dsp.exec_cmd("/usr/libexec/ben-bazzite/keybinds"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock -c /usr/share/hypr/hyprlock.conf"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("wlogout"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + SPACE", hl.dsp.window.float())
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("scratch"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Focus and window movement.
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + UP", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + SHIFT + LEFT", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + UP", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + DOWN", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + TAB", hl.dsp.window.cycle_next({ next = true }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Workspaces 1-9.
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Screenshots, audio, brightness, and media keys.
hl.bind("Print", hl.dsp.exec_cmd("/usr/libexec/ben-bazzite/screenshot region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("/usr/libexec/ben-bazzite/screenshot output"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume +5 --max-volume 100"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume -5 --max-volume 100"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness +5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -5"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Keep the wallpaper path referenced here so image validation catches drift.
assert(wallpaper == "/usr/share/backgrounds/ben-bazzite/aurora-glass.png")
