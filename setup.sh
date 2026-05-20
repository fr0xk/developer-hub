#!/bin/bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
BACKUP_BASE="$HOME/.dotfiles_backup_$(date +%s)"
ENVIRONMENT="linux"
[ -d "/data/data/com.termux" ] && ENVIRONMENT="termux"
[ ! -d "$DOTFILES_DIR" ] && exit 1
setup_dirs() {
    mkdir -p "$HOME/.config" "$HOME/.local/bin"
    [ "$ENVIRONMENT" == "termux" ] && mkdir -p "$HOME/.termux"
}
deploy_file() {
    [ ! -f "$1" ] && [ ! -d "$1" ] && return
    if [ -e "$2" ]; then
        mkdir -p "$BACKUP_BASE"
        mv "$2" "$BACKUP_BASE/"
    fi
    cp -r "$1" "$2"
}
save_file() {
    [ ! -f "$1" ] && [ ! -d "$1" ] && return
    cp -r "$1" "$2"
}
run_deploy() {
    setup_dirs
    find "$DOTFILES_DIR" -maxdepth 1 -name ".*" -type f | while read -r file; do
        deploy_file "$file" "$HOME/$(basename "$file")"
    done
    if [ -d "$DOTFILES_DIR/.config" ]; then
        find "$DOTFILES_DIR/.config" -maxdepth 1 -mindepth 1 | while read -r conf; do
            deploy_file "$conf" "$HOME/.config/$(basename "$conf")"
        done
    fi
    [ -d "$DOTFILES_DIR/.vim" ] && deploy_file "$DOTFILES_DIR/.vim" "$HOME/.vim"
    if [ "$ENVIRONMENT" == "termux" ] && [ -d "$DOTFILES_DIR/.termux" ]; then
        deploy_file "$DOTFILES_DIR/.termux/colors.properties" "$HOME/.termux/colors.properties"
        deploy_file "$DOTFILES_DIR/.termux/termux.properties" "$HOME/.termux/termux.properties"
    fi
    [ -d "$PROJECT_ROOT/scripts" ] && chmod +x "$PROJECT_ROOT/scripts/"* 2>/dev/null || true
}
run_save() {
    find "$DOTFILES_DIR" -maxdepth 1 -name ".*" -type f | while read -r file; do
        save_file "$HOME/$(basename "$file")" "$file"
    done
    if [ -d "$DOTFILES_DIR/.config" ]; then
        find "$DOTFILES_DIR/.config" -maxdepth 1 -mindepth 1 | while read -r conf; do
            save_file "$HOME/.config/$(basename "$conf")" "$conf"
        done
    fi
    [ -d "$DOTFILES_DIR/.vim" ] && save_file "$HOME/.vim" "$DOTFILES_DIR/.vim"
    if [ "$ENVIRONMENT" == "termux" ] && [ -d "$DOTFILES_DIR/.termux" ]; then
        save_file "$HOME/.termux/colors.properties" "$DOTFILES_DIR/.termux/colors.properties"
        save_file "$HOME/.termux/termux.properties" "$DOTFILES_DIR/.termux/termux.properties"
    fi
}
main() {
    [ "${1:-}" == "--save" ] && run_save || run_deploy
}
main "$@"
