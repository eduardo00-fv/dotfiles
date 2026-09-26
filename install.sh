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
for f in "$REPO"/bin/*; do
    enlazar "$f" "$HOME/.local/bin/$(basename "$f")"
done
echo "Listo. Paquetes necesarios: ver README.md"
