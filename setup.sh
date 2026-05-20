#!/bin/bash
# setup.sh - Robust environment setup and dotfiles sync
# Reorganized for clarity and safety.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
BACKUP_BASE="$HOME/.dotfiles_backup_$(date +%s)"

log() { echo -e "[\033[0;34mINFO\033[0m] $1"; }
error() { echo -e "[\033[0;31mERROR\033[0m] $1"; exit 1; }

# Safety check
if [ ! -d "$DOTFILES_DIR" ]; then
    error "dotfiles directory not found. Please run this script from the project root."
fi

# Detect environment
ENVIRONMENT="linux"
if [ -d "/data/data/com.termux" ]; then
    ENVIRONMENT="termux"
fi

setup_dirs() {
    log "Preparing directories..."
    mkdir -p "$HOME/.config" "$HOME/.local/bin"
    if [ "$ENVIRONMENT" == "termux" ]; then
        mkdir -p "$HOME/.termux"
    fi
}

sync_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ ! -e "$src" ]; then
        log "Skipping $name: Source not found"
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        # Check if it's already a symlink to the correct place
        if [ -L "$dst" ] && [ "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]; then
            log "✓ $name is already synced"
            return
        fi

        # Backup existing
        mkdir -p "$BACKUP_BASE"
        mv "$dst" "$BACKUP_BASE/"
        log "Backed up existing $name to $BACKUP_BASE"
    fi

    ln -sf "$src" "$dst"
    log "✓ Synced $name"
}

sync_dotfiles() {
    log "Syncing dotfiles..."
    
    # Core dotfiles in the dotfiles/ directory
    # Find all files starting with '.' in the dotfiles directory
    find "$DOTFILES_DIR" -maxdepth 1 -name ".*" -type f | while read -r file; do
        filename=$(basename "$file")
        sync_file "$file" "$HOME/$filename" "$filename"
    done

    # Specialized directories
    if [ -d "$DOTFILES_DIR/.config" ]; then
        # Sync subdirectories of .config individually to avoid obliterating the whole dir
        find "$DOTFILES_DIR/.config" -maxdepth 1 -mindepth 1 | while read -r conf; do
            confname=$(basename "$conf")
            sync_file "$conf" "$HOME/.config/$confname" ".config/$confname"
        done
    fi

    if [ -d "$DOTFILES_DIR/.vim" ]; then
        sync_file "$DOTFILES_DIR/.vim" "$HOME/.vim" ".vim directory"
    fi

    if [ "$ENVIRONMENT" == "termux" ] && [ -d "$DOTFILES_DIR/.termux" ]; then
        sync_file "$DOTFILES_DIR/.termux/colors.properties" "$HOME/.termux/colors.properties" "termux colors"
        sync_file "$DOTFILES_DIR/.termux/termux.properties" "$HOME/.termux/termux.properties" "termux properties"
    fi
}

finalize() {
    log "Finalizing..."
    # Ensure scripts are executable
    if [ -d "$PROJECT_ROOT/scripts" ]; then
        chmod +x "$PROJECT_ROOT/scripts/"* 2>/dev/null || true
    fi
    log "\033[0;32mSetup Complete!\033[0m"
    if [ -d "$BACKUP_BASE" ]; then
        log "Backups were saved to: $BACKUP_BASE"
    fi
}

main() {
    echo "--- Developer Hub Setup ---"
    setup_dirs
    sync_dotfiles
    finalize
}

main "$@"
