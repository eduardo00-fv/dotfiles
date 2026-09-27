# Agregar al final de ~/.zshrc:  source ~/dotfiles/zsh/tinta.zsh

# fastfetch con el casco girando y THRAIN forjándose (FORJA_QUIETA=1 lo deja estático)
~/.config/fastfetch/forja.py

# yazi: `y` abre el explorador y al salir (q) te deja parado en la carpeta donde estabas
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
