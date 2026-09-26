-- Hyprland config (formato Lua, requerido desde 0.57)
-- Convertido desde hyprland.conf el 2026-08-08. El .conf original se conserva
-- como respaldo pero YA NO SE LEE: Hyprland prefiere hyprland.lua si existe.

-------------------------------
---- VARIABLES DE ENTORNO -----
-------------------------------

-- NVIDIA Optimus (Intel iGPU + MX250)
-- Módulo nvidia NO existe para kernel linux-lts → estas env rompían el GLX
-- de las apps 3D (Webots todo gris). Comentadas 2026-07-08 (usar Intel/Mesa).
-- Reactivar solo si se instala nvidia-lts y se quiere la dGPU (PRIME offload).
hl.env("LIBVA_DRIVER_NAME", "iHD")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("NVD_BACKEND", "direct")

-- Wayland general
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XAUTHORITY", os.getenv("HOME") .. "/.Xauthority")


------------------
---- MONITORES ----
------------------

-- El externo va con 'preferred' + 'auto-left': antes estaba fijado a
-- 1920x1080@60 en 0x0, así que cualquier monitor con otra resolución nativa
-- (1440p, 75Hz, un TV 4K...) no aplicaba el modo y descolocaba el eDP.
hl.monitor({ output = "eDP-1",     mode = "1920x1080@60", position = "0x0",       scale = 1 })
hl.monitor({ output = "HDMI-A-1",  mode = "preferred",    position = "auto-left", scale = 1 })
hl.monitor({ output = "",          mode = "preferred",    position = "auto",      scale = 1 })


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("bash -c 'xauth add :0 . $(mcookie)'")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("swaybg -o '*' -i ~/Pictures/Walpapers/lockscreen-active.jpg -m fill")
    hl.exec_cmd("~/.config/hypr/random-wallpaper.sh")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("python3 ~/.config/hypr/wallpaper-daemon.py")
    hl.exec_cmd("~/.config/eww/restart.sh")   -- widgets de escritorio
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


---------------------------
---- TECLADO Y TOUCHPAD ----
---------------------------

hl.config({
    input = {
        kb_layout          = "us",
        numlock_by_default = true,
        follow_mouse       = 1,

        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name   = "wacom-one-by-wacom-s-pen",
    output = "eDP-1",
})


--------------------------
---- APARIENCIA GENERAL ----
--------------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = "rgba(5e5245cc)",
            inactive_border = "rgba(2a241d99)",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 8,

        blur = {
            enabled = true,
            size    = 6,
            passes  = 2,
        },

        shadow = {
            enabled = true,
            range   = 15,
            color   = "rgba(0d0b09cc)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        background_color        = "rgb(000000)",
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },

    -- La pantalla "Hyprland has been updated!" salía en CADA login porque
    -- ~/.local/state/hypr/ no existía y Hyprland no podía guardar lastVersion.
    -- El directorio ya está creado; esto además la desactiva del todo.
    ecosystem = {
        no_update_news = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })


---------------------------
---- ATAJOS DE TECLADO ----
---------------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("xournalpp"))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("~/.config/hypr/random-wallpaper.sh"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + F",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",         hl.dsp.workspace.toggle_special("minimized"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:minimized" }))
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("~/.config/rofi/powermenu.sh"))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("sh -c 'cliphist list | rofi -dmenu | cliphist decode | wl-copy'"))

-- Workspaces
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- Foco y ventanas entre monitores
hl.bind(mainMod .. " + comma",          hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + period",         hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "r" }))

-- Mover ventanas con ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Foco con teclado
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mover ventanas con teclado
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Volumen
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),             { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),            { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),          { locked = true })

-- Brillo
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd([[sh -c 'mkdir -p ~/Pictures/Screenshots && grim - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy']]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[sh -c 'mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy']]))

-- Power management
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("systemctl reboot"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.config/eww/scripts/todo.sh add"))   -- nueva tarea en el to-do


---------------------------
---- REGLAS DE VENTANA ----
---------------------------

-- Widgets de eww (clima/sistema): desenfoque detrás de las tarjetas translúcidas
hl.layer_rule({
    name         = "eww-blur",
    match        = { namespace = "^gtk-layer-shell$" },
    blur         = true,
    ignore_alpha = 0.3,
})

hl.window_rule({
    name  = "gsimplecal-float",
    match = { class = "^(gsimplecal)$" },

    float = true,
    move  = "43% 4%",
})
