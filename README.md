# Tinta · dotfiles de Hyprland

![escritorio](capturas/escritorio.jpg)

Arch Linux + Hyprland con una paleta cálida y mate (tinta, maple, terracota) en lugar de neón.
Fotos 4K de fondo que rotan solas y una columna de widgets en el escritorio.

## Paleta

| | nombre | hex |
|---|---|---|
| ![](https://placehold.co/16x16/1d1a16/1d1a16.png) | tinta (fondo) | `#1d1a16` |
| ![](https://placehold.co/16x16/2a241d/2a241d.png) | superficie | `#2a241d` |
| ![](https://placehold.co/16x16/e0551f/e0551f.png) | terracota (acento) | `#e0551f` |
| ![](https://placehold.co/16x16/ecdcc0/ecdcc0.png) | crema (texto) | `#ecdcc0` |
| ![](https://placehold.co/16x16/bfae90/bfae90.png) | arena (texto 2) | `#bfae90` |
| ![](https://placehold.co/16x16/5e5245/5e5245.png) | nogal (bordes) | `#5e5245` |
| ![](https://placehold.co/16x16/d9a441/d9a441.png) | ocre | `#d9a441` |
| ![](https://placehold.co/16x16/93a35a/93a35a.png) | musgo (segundo acento) | `#93a35a` |
| ![](https://placehold.co/16x16/8a9a5b/8a9a5b.png) | oliva | `#8a9a5b` |

## Qué hay

| | |
|---|---|
| **WM** | Hyprland 0.56, config en Lua (`hypr/hyprland.lua`) |
| **Barra** | Waybar en "islas" flotantes: workspaces numerados (el activo se estira en una píldora), música + reloj, sistema, AirPods, cafeína, apagado |
| **Widgets** | eww: reloj con accesos, música (Apple Music web vía MPRIS), clima (wttr.in), notificaciones (swaync), pomodoro, to-do |
| **Fuente** | CaskaydiaCove Nerd Font en todo |
| **Fondo** | dos modos: fotos 4K o degradados con grano generados en la paleta (`fondos/generar-degradados.py`); swaybg con `wallpaper-daemon.py` rota cada 30 min, pausa en pantalla completa y reaplica al conectar monitores. Super+W cambia |
| **Lock / idle** | hyprlock + hypridle: fondo actual desenfocado, marco editorial, reloj delgado y una frase para hacer *lock in* en Fraunces suave (`hypr/frases-thrain.txt`) |
| **Terminal** | kitty + starship + fastfetch + atuin (tema `tinta`) |
| **Menús** | rofi (lanzador y menú de apagado), swaync |

## Atajos útiles

| | |
|---|---|
| Super+W | siguiente fondo |
| Super+Shift+W | cambiar entre fotos y degradados |
| Super+T | nueva tarea en el to-do |
| Super+M | Apple Music: abrir / mostrar / ocultar su cajón (sigue sonando oculta) |
| Super+Esc | menú de apagado |
| Super+Shift+S | suspender |

## Instalar

```bash
git clone https://github.com/eduardo00-fv/dotfiles ~/dotfiles && cd ~/dotfiles
./install.sh      # symlinks a ~/.config y ~/.local/bin (respalda lo que exista)
```

Paquetes (Arch): `hyprland hyprlock hypridle waybar eww swaybg swaync rofi kitty starship fastfetch atuin playerctl pacman-contrib jq python python-numpy python-pillow ttf-cascadia-code-nerd`
y del AUR: `yay` (para contar actualizaciones AUR).

Las fotos de fondo van en `~/Pictures/Walpapers/fotos/` (no están en el repo). Los degradados se generan con
`python3 fondos/generar-degradados.py 3840 2160 ~/Pictures/Walpapers/degradados`.

## Personalizar

- `bin/airpods-toggle`: pon la MAC de tus audífonos en `~/.config/airpods-mac` (`bluetoothctl devices`).
- `eww/eww.yuck`: accesos rápidos del reloj y monitor (`:monitor` usa el modelo de la pantalla, ver `hyprctl monitors`).
- `eww/scripts/weather.py`: `CITY` vacío = ubicación por IP.

## Mantener al día

```bash
./sync.sh && git add -A && git commit -m "…"
```
