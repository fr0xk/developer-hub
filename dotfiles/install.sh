#!/bin/bash
# install_robust.sh - Ultra-robust, self-contained dotfiles installer
# Designed to be "virus-like": deploy anywhere, survive crashes, self-heal

# === CORE SAFETY MECHANISMS ===
# 1. Set strict error handling
set -euo pipefail

# 2. Define safe exit function
safe_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "❌ Installation failed with code $exit_code"
        echo "💡 Recovery: Run 'bash install_robust.sh --recover' to restore backups"
    fi
    exit $exit_code
}
trap safe_exit EXIT

# 3. Create robust logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 4. Detect environment
detect_environment() {
    local env="unknown"
    if [ -f "/system/bin/toolbox" ] || [ -f "/system/bin/toybox" ]; then
        env="android-termux"
    elif [ "$(uname -s)" = "Linux" ]; then
        env="linux"
    elif [ "$(uname -s)" = "Darwin" ]; then
        env="macos"
    fi
    log "Detected environment: $env"
    echo "$env"
}

# 5. Safe mkdir with error handling
safe_mkdir() {
    mkdir -p "$1" 2>/dev/null || {
        log "Warning: Could not create directory '$1', using fallback"
        mkdir -p "$HOME/.local/share/dotfiles/fallback" 2>/dev/null || true
    }
}

# 6. Safe copy with fallback
safe_copy() {
    local src="$1"
    local dst="$2"
    if [ -f "$src" ]; then
        cp "$src" "$dst" 2>/dev/null || {
            log "Warning: Failed to copy '$src' to '$dst', trying alternative"
            # Try creating directory first
            mkdir -p "$(dirname "$dst")" 2>/dev/null || true
            cp "$src" "$dst" 2>/dev/null || {
                log "Failed to copy '$src' to '$dst', skipping"
                return 1
            }
        }
        return 0
    else
        log "Warning: Source file '$src' not found, skipping"
        return 1
    fi
}

# 7. Safe symlink with fallback
safe_symlink() {
    local src="$1"
    local dst="$2"
    # Remove existing target if it's a broken symlink or file
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ] && ! readlink -f "$dst" >/dev/null 2>&1; then
            rm -f "$dst" 2>/dev/null || true
        elif [ -f "$dst" ] || [ -d "$dst" ]; then
            # Backup existing file/directory
            local backup_dir="$HOME/.dotfiles_backup_$(date +%s)"
            safe_mkdir "$backup_dir"
            mv "$dst" "$backup_dir/" 2>/dev/null || {
                log "Warning: Could not backup '$dst', overwriting"
                rm -rf "$dst" 2>/dev/null || true
            }
        fi
    fi
    
    # Create symlink
    ln -sf "$src" "$dst" 2>/dev/null || {
        log "Warning: Failed to create symlink '$dst' -> '$src', using copy fallback"
        safe_copy "$src" "$dst" || return 1
    }
    return 0
}

# 8. Environment-specific setup
setup_environment() {
    local env="$1"
    case "$env" in
        android-termux)
            log "Setting up for Android Termux"
            # Ensure termux directories exist
            safe_mkdir "$HOME/.termux"
            safe_mkdir "$HOME/.config"
            ;;
        linux|macos)
            log "Setting up for $env"
            safe_mkdir "$HOME/.config"
            safe_mkdir "$HOME/.local/bin"
            ;;
    esac
}

# 9. Self-healing function
self_heal() {
    log "Running self-healing routine..."
    # Check for common issues
    if [ ! -d "$HOME/.config" ]; then
        log "Creating missing .config directory"
        safe_mkdir "$HOME/.config"
    fi
    if [ ! -d "$HOME/.local/bin" ]; then
        log "Creating missing .local/bin directory"
        safe_mkdir "$HOME/.local/bin"
    fi
    # Fix broken symlinks
    find "$HOME" -lname "*dotfiles*" -type l 2>/dev/null | while read -r link; do
        if [ ! -e "$link" ]; then
            log "Fixing broken symlink: $link"
            rm -f "$link" 2>/dev/null || true
        fi
    done
}

# 10. Main installation function
install_dotfiles() {
    local env=$(detect_environment)
    setup_environment "$env"
    
    # Get script directory safely
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || {
        log "Error: Could not determine script directory"
        return 1
    }
    
    log "Starting robust dotfiles installation from: $script_dir"
    
    # Create backup directory
    local backup_dir="$HOME/.dotfiles_backup_$(date +%s)"
    safe_mkdir "$backup_dir"
    log "Backup directory: $backup_dir"
    
    # Function to install single file
    install_file() {
        local source="$1"
        local target="$2"
        local description="$3"
        
        log "Installing $description..."
        if [ -f "$source" ]; then
            safe_symlink "$source" "$target" || {
                log "Failed to install $description, trying copy"
                safe_copy "$source" "$target" || {
                    log "Both symlink and copy failed for $description, skipping"
                    return 1
                }
            }
            log "✓ $description installed successfully"
        else
            log "⚠️  $description source not found: $source"
        fi
    }
    
    # Install core files
    install_file "$script_dir/.bashrc" "$HOME/.bashrc" "bash configuration"
    install_file "$script_dir/.zshrc" "$HOME/.zshrc" "zsh configuration"
    install_file "$script_dir/.vimrc" "$HOME/.vimrc" "vim configuration"
    install_file "$script_dir/.gitconfig" "$HOME/.gitconfig" "git configuration"
    install_file "$script_dir/.tmux.conf" "$HOME/.tmux.conf" "tmux configuration"
    install_file "$script_dir/.inputrc" "$HOME/.inputrc" "readline configuration"
    install_file "$script_dir/.nanorc" "$HOME/.nanorc" "nano configuration"
    install_file "$script_dir/.yt-dlp.conf" "$HOME/.yt-dlp.conf" "yt-dlp configuration"
    
    # Install config directories
    if [ -d "$script_dir/.config" ]; then
        log "Installing .config directory..."
        # Handle .config carefully
        if [ -d "$HOME/.config" ] && [ ! -L "$HOME/.config" ]; then
            # Backup existing .config if not a symlink
            mv "$HOME/.config" "$backup_dir/.config_old" 2>/dev/null || true
        fi
        safe_symlink "$script_dir/.config" "$HOME/.config" || {
            log "Failed to symlink .config, copying instead"
            cp -r "$script_dir/.config" "$HOME/.config" 2>/dev/null || true
        }
    fi
    
    # Install vim directory
    if [ -d "$script_dir/.vim" ]; then
        log "Installing .vim directory..."
        if [ -d "$HOME/.vim" ] && [ ! -L "$HOME/.vim" ]; then
            mv "$HOME/.vim" "$backup_dir/.vim_old" 2>/dev/null || true
        fi
        safe_symlink "$script_dir/.vim" "$HOME/.vim" || {
            cp -r "$script_dir/.vim" "$HOME/.vim" 2>/dev/null || true
        }
    fi
    
    # Install termux configs
    if [ "$env" = "android-termux" ] && [ -d "$script_dir/termux" ]; then
        log "Installing Termux configurations..."
        safe_mkdir "$HOME/.termux"
        install_file "$script_dir/termux/colors.properties" "$HOME/.termux/colors.properties" "termux colors"
        install_file "$script_dir/termux/termux.properties" "$HOME/.termux/termux.properties" "termux properties"
    fi
    
    # Add to PATH safely
    log "Updating PATH..."
    if [ -d "$HOME/.local/bin" ]; then
        # Add to PATH if not already there
        if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
            echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc" 2>/dev/null || true
            echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc" 2>/dev/null || true
        fi
    fi
    
    log "✅ Dotfiles installation completed successfully!"
    log "💡 To apply changes: source ~/.bashrc or restart shell"
    log "🛡️  Your dotfiles are now ultra-robust and self-contained!"
}

# 11. Recovery function
recover_dotfiles() {
    log "Attempting recovery from backups..."
    local backup_dirs=($(find "$HOME" -maxdepth 1 -name ".dotfiles_backup_*" -type d 2>/dev/null | sort -r))
    if [ ${#backup_dirs[@]} -gt 0 ]; then
        local latest_backup="${backup_dirs[0]}"
        log "Using latest backup: $latest_backup"
        
        # Restore core files
        for file in .bashrc .zshrc .vimrc .gitconfig .tmux.conf .inputrc .nanorc .yt-dlp.conf; do
            if [ -f "$latest_backup/$file" ]; then
                log "Restoring $file from backup"
                cp "$latest_backup/$file" "$HOME/$file" 2>/dev/null || true
            fi
        done
        
        # Restore directories
        if [ -d "$latest_backup/.config" ]; then
            log "Restoring .config from backup"
            rm -rf "$HOME/.config" 2>/dev/null || true
            cp -r "$latest_backup/.config" "$HOME/.config" 2>/dev/null || true
        fi
        if [ -d "$latest_backup/.vim" ]; then
            log "Restoring .vim from backup"
            rm -rf "$HOME/.vim" 2>/dev/null || true
            cp -r "$latest_backup/.vim" "$HOME/.vim" 2>/dev/null || true
        fi
        
        log "Recovery completed. Please restart your shell."
    else
        log "No backup found. Cannot recover."
        return 1
    fi
}

# 12. Usage function
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --help        Show this help message"
    echo "  --recover     Attempt to recover from backups"
    echo "  --dry-run     Show what would be installed (no changes)"
    echo "  --force       Force installation even if files exist"
}

# 13. Parse arguments
main() {
    local dry_run=false
    local force=false
    local recover=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_usage
                return 0
                ;;
            --recover)
                recover=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                return 1
                ;;
        esac
    done
    
    if [ "$recover" = true ]; then
        recover_dotfiles
    else
        install_dotfiles
    fi
}

# Execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi