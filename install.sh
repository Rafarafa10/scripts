#!/bin/bash
# install.sh — Crea symlinks de dotfiles a sus ubicaciones reales
# Uso: cd ~/dotfiles && bash install.sh
# Seguro de ejecutar múltiples veces (idempotente)

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date '+%Y%m%d_%H%M%S')"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[BACKUP]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Crea symlink con backup del archivo original si existe
link_file() {
    local src="$1"
    local dst="$2"

    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$dst")"

    # Si ya es el symlink correcto, skip
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        info "$dst ya apunta a $src"
        return
    fi

    # Backup si existe archivo/symlink previo
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
        warn "Backup: $dst -> $BACKUP_DIR/$(basename "$dst")"
    fi

    ln -s "$src" "$dst"
    info "$dst -> $src"
}

echo ""
echo "=== Instalando dotfiles ==="
echo ""

# --- Symlinks principales ---
link_file "$DOTFILES/bash/bashrc"               "$HOME/.bashrc"
link_file "$DOTFILES/bash/profile"               "$HOME/.profile"
link_file "$DOTFILES/git/gitconfig"              "$HOME/.gitconfig"
link_file "$DOTFILES/tmux/tmux.conf"             "$HOME/.tmux.conf"
link_file "$DOTFILES/wezterm/wezterm.lua"        "$HOME/.config/wezterm/wezterm.lua"
link_file "$DOTFILES/claude/update_claude_md.sh" "$HOME/update_claude_md.sh"
link_file "$DOTFILES/claude/close_session.sh"    "$HOME/.claude/scripts/close_session.sh"
link_file "$DOTFILES/claude/aliases.sh"          "$HOME/.claude/scripts/claude/aliases.sh"

# --- Hacer scripts ejecutables ---
chmod +x "$DOTFILES/scripts/"*
chmod +x "$DOTFILES/claude/"*.sh

echo ""
echo "=== Limpieza ==="
echo ""

# Eliminar clon viejo de ~/scripts/ si existe y es el mismo repo
if [ -d "$HOME/scripts/.git" ]; then
    REMOTE=$(git -C "$HOME/scripts" remote get-url origin 2>/dev/null)
    if [[ "$REMOTE" == *"Rafarafa10/scripts"* ]] || [[ "$REMOTE" == *"Rafarafa10/dotfiles"* ]]; then
        rm -rf "$HOME/scripts"
        info "Eliminado ~/scripts/ (clon viejo)"
    fi
fi

echo ""
echo "=== Instalacion completa ==="
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups guardados en: $BACKUP_DIR"
fi
echo "Ejecuta 'source ~/.bashrc' para aplicar cambios."
echo ""
