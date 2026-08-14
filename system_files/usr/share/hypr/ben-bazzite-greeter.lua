-- Minimal compositor session for the Ben Bazzite Quickshell greeter.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        border_size = 0,
        gaps_in = 0,
        gaps_out = 0,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = "#070b18",
    },
    animations = {
        enabled = false,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd('sh -c "qs -p /etc/xdg/quickshell/ben-bazzite-greeter; hyprctl dispatch exit"')
end)
