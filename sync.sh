#!/usr/bin/env bash
# Copia la config en uso (~/.config, ~/.local/bin) a este repo.
# Correr después de cambiar algo:  ./sync.sh && git add -A && git commit -m "..."
set -eu
cd "$(dirname "$0")"
mkdir -p config
EXCL=(--exclude '*.bak*' --exclude '*.arcade' --exclude '*.video-*' --exclude '__pycache__' --exclude '*.log')

for d in hypr waybar eww kitty rofi swaync fastfetch atuin cava yazi quickshell; do
    rsync -a --delete "${EXCL[@]}" "$HOME/.config/$d/" "config/$d/"
done
# restos de configs viejas que ya no se usan
rm -f config/hypr/hyprland.conf config/hypr/hyprpaper.conf config/hypr/mpvpaper-fullscreen-pause.py
rm -f config/atuin/themes/arcade.toml config/atuin/themes/retro.toml
cp "$HOME/.config/starship.toml" config/starship.toml

# GTK: solo el tema (gtk-3.0 también guarda marcadores personales, no se sube)
mkdir -p gtk
cp "$HOME/.config/gtk-4.0/gtk.css" gtk/gtk.css
cp "$HOME/.config/gtk-4.0/settings.ini" gtk/settings.ini

# tema Tinta de VS Code (fuente del .vsix)
mkdir -p vscode
rsync -a --delete "$HOME/.local/src/tinta-vscode/" vscode/tinta-theme/

mkdir -p bin
for f in pomodoro toggle-calendar airpods-toggle apple-music; do cp "$HOME/.local/bin/$f" bin/; done
mkdir -p fondos && cp "$HOME/Pictures/Walpapers/degradados/generar.py" fondos/generar-degradados.py
echo "sincronizado: $(find config bin -type f | wc -l) archivos"
