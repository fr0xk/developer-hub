#!/bin/bash
# setup.sh - Robust environment setup and dotfiles sync
# Reorganized for clarity and safety.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
BACKUP_BASE="$HOME/.dotfiles_backup_$(date +%s)"

log() { echo -e "[\033[0;34mINFO\033[0m] $1"; }
warn() { echo -e "[\033[0;33mWARN\033[0m] $1"; }
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

# Direction: repo -> home (Deploy)
deploy_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ ! -f "$src" ] && [ ! -d "$src" ]; then
        warn "Source missing: $name. Skipping."
        return
    fi

    if [ -e "$dst" ]; then
        mkdir -p "$BACKUP_BASE"
        mv "$dst" "$BACKUP_BASE/"
        log "Backed up existing $name to $BACKUP_BASE"
    fi

    cp -r "$src" "$dst"
    log "✓ Deployed $name"
}

# Direction: home -> repo (Save)
save_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ ! -f "$src" ] && [ ! -d "$src" ]; then
        return
    fi

    log "Saving $name back to repository..."
    cp -r "$src" "$dst"
}

run_deploy() {
    echo "--- Deploying Repo to Home ---"
    setup_dirs
    
    # Core dotfiles
    find "$DOTFILES_DIR" -maxdepth 1 -name ".*" -type f | while read -r file; do
        filename=$(basename "$file")
        deploy_file "$file" "$HOME/$filename" "$filename"
    done

    # .config
    if [ -d "$DOTFILES_DIR/.config" ]; then
        find "$DOTFILES_DIR/.config" -maxdepth 1 -mindepth 1 | while read -r conf; do
            confname=$(basename "$conf")
            deploy_file "$conf" "$HOME/.config/$confname" ".config/$confname"
        done
    fi

    # .vim
    if [ -d "$DOTFILES_DIR/.vim" ]; then
        deploy_file "$DOTFILES_DIR/.vim" "$HOME/.vim" ".vim directory"
    fi

    # Termux
    if [ "$ENVIRONMENT" == "termux" ] && [ -d "$DOTFILES_DIR/.termux" ]; then
        deploy_file "$DOTFILES_DIR/.termux/colors.properties" "$HOME/.termux/colors.properties" "termux colors"
        deploy_file "$DOTFILES_DIR/.termux/termux.properties" "$HOME/.termux/termux.properties" "termux properties"
    fi
    
    # Finalize permissions
    if [ -d "$PROJECT_ROOT/scripts" ]; then
        chmod +x "$PROJECT_ROOT/scripts/"* 2>/dev/null || true
    fi
    log "\033[0;32mDeployment Complete!\033[0m"
}

run_save() {
    echo "--- Saving Home to Repo ---"
    
    find "$DOTFILES_DIR" -maxdepth 1 -name ".*" -type f | while read -r file; do
        filename=$(basename "$file")
        save_file "$HOME/$filename" "$file" "$filename"
    done

    if [ -d "$DOTFILES_DIR/.config" ]; then
        find "$DOTFILES_DIR/.config" -maxdepth 1 -mindepth 1 | while read -r conf; do
            confname=$(basename "$conf")
            save_file "$HOME/.config/$confname" "$conf" ".config/$confname"
        done
    fi

    if [ -d "$DOTFILES_DIR/.vim" ]; then
        save_file "$HOME/.vim" "$DOTFILES_DIR/.vim" ".vim directory"
    fi

    if [ "$ENVIRONMENT" == "termux" ] && [ -d "$DOTFILES_DIR/.termux" ]; then
        save_file "$HOME/.termux/colors.properties" "$DOTFILES_DIR/.termux/colors.properties" "termux colors"
        save_file "$HOME/.termux/termux.properties" "$DOTFILES_DIR/.termux/termux.properties" "termux properties"
    fi
    log "\033[0;32mLocal changes saved to repository.\033[0m"
}

main() {
    local mode="deploy"
    while [[ $# -gt 0 ]]; do
        case $1 in
            --save) mode="save" ;;
            *) break ;;
        esac
        shift
    done

    if [ "$mode" == "save" ]; then
        run_save
    else
        run_deploy
    fi
}

main "$@"


main "$@"
