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
| ![](https://placehold.co/16x16/8a9a5b/8a9a5b.png) | oliva | `#8a9a5b` |

## Qué hay

| | |
|---|---|
| **WM** | Hyprland 0.56, config en Lua (`hypr/hyprland.lua`) |
| **Barra** | Waybar en "islas" flotantes: workspaces como puntos (el activo se estira), música + reloj, sistema, AirPods, cafeína, apagado |
| **Widgets** | eww: reloj con accesos, música (Apple Music web vía MPRIS), clima (wttr.in), notificaciones (swaync), pomodoro, to-do |
| **Fondo** | swaybg con fotos fijas en 4K; `wallpaper-daemon.py` rota cada 30 min, pausa en pantalla completa y reaplica al conectar monitores. Super+W cambia |
| **Lock / idle** | hyprlock + hypridle, usando la misma foto del fondo |
| **Terminal** | kitty + starship + fastfetch + atuin (tema `tinta`) |
| **Menús** | rofi (lanzador y menú de apagado), swaync |

## Atajos útiles

| | |
|---|---|
| Super+W | siguiente fondo |
| Super+T | nueva tarea en el to-do |
| Super+Esc | menú de apagado |
| Super+Shift+S | suspender |

## Instalar

```bash
git clone <este repo> ~/dotfiles && cd ~/dotfiles
./install.sh      # symlinks a ~/.config y ~/.local/bin (respalda lo que exista)
```

Paquetes (Arch): `hyprland hyprlock hypridle waybar eww swaybg swaync rofi kitty starship fastfetch atuin playerctl pacman-contrib jq python ttf-cascadia-code-nerd`
y del AUR: `yay` (para contar actualizaciones AUR).

Las fotos de fondo van en `~/Pictures/Walpapers/fotos/` (no están en el repo).

## Personalizar

- `bin/airpods-toggle`: cambia la MAC por la de tus audífonos.
- `eww/eww.yuck`: accesos rápidos del reloj y monitor (`:monitor` usa el modelo de la pantalla, ver `hyprctl monitors`).
- `eww/scripts/weather.py`: `CITY` vacío = ubicación por IP.

## Mantener al día

```bash
./sync.sh && git add -A && git commit -m "…"
```
