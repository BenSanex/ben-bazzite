-- Ben Bazzite Stage 1: minimal Hyprland 0.56 configuration.
-- Hyprland copies this fallback to ~/.config/hypr/hyprland.lua on first use.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

-- Current upstream NVIDIA guidance. Bazzite continues to own the driver,
-- kernel module, modesetting, and gaming-stack configuration.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = false,
    },
    input = {
        follow_mouse = 1,
    },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
    },
})

-- Minimal controls for a usable first session. The full control scheme lands
-- in Stage 2 after this package/session baseline has built successfully.
hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
