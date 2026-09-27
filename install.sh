#!/usr/bin/env bash
# Instala estos dotfiles en otra máquina con symlinks hacia el repo.
# Lo que ya exista se mueve a ~/.dotfiles-respaldo-<fecha>/ antes de enlazar.
set -eu
REPO="$(cd "$(dirname "$0")" && pwd)"
RESP="$HOME/.dotfiles-respaldo-$(date +%Y%m%d-%H%M%S)"

enlazar() {  # enlazar <origen en el repo> <destino>
    local src="$1" dst="$2"
    [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ] && return
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$RESP"; mv "$dst" "$RESP/"; echo "respaldo: $dst"
    fi
    mkdir -p "$(dirname "$dst")"; ln -s "$src" "$dst"; echo "enlazado: $dst"
}

for d in "$REPO"/config/*/; do
    enlazar "${d%/}" "$HOME/.config/$(basename "$d")"
done
enlazar "$REPO/config/starship.toml" "$HOME/.config/starship.toml"
for v in gtk-3.0 gtk-4.0; do
    enlazar "$REPO/gtk/gtk.css" "$HOME/.config/$v/gtk.css"
    enlazar "$REPO/gtk/settings.ini" "$HOME/.config/$v/settings.ini"
done
for f in "$REPO"/bin/*; do
    enlazar "$f" "$HOME/.local/bin/$(basename "$f")"
done
# tema de VS Code
if command -v code >/dev/null; then
    (cd "$REPO/vscode/tinta-theme" && rm -f /tmp/tinta-theme.vsix && zip -qr /tmp/tinta-theme.vsix '[Content_Types].xml' extension.vsixmanifest extension) \
        && code --install-extension /tmp/tinta-theme.vsix >/dev/null && echo "VS Code: tema Tinta instalado"
fi
echo "Listo. Paquetes necesarios y pasos a mano (Brave, zsh): ver README.md"
