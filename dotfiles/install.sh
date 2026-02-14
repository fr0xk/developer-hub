#!/bin/bash
# install-dotfiles.sh - Install Unixporn light theme dotfiles

echo "Installing Unixporn light theme dotfiles..."

# Create backup directory
mkdir -p ~/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)

# Function to backup and link a file
backup_and_link() {
    local source_file=$1
    local target_file=$2
    local backup_dir=$3
    
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        echo "Backing up $target_file"
        mv "$target_file" "$backup_dir/"
    fi
    
    echo "Linking $source_file to $target_file"
    ln -sf "$source_file" "$target_file"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Link main configuration files
backup_and_link "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
backup_and_link "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
backup_and_link "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
backup_and_link "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"

# Link config directory
if [ -d "$HOME/.config" ]; then
    if [ ! -d "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)/.config" ]; then
        mkdir -p "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)/.config"
    fi
    mv "$HOME/.config" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)/.config_old"
fi
backup_and_link "$SCRIPT_DIR/.config" "$HOME/.config" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"

# Link additional files from misc directory
backup_and_link "$SCRIPT_DIR/misc/inputrc" "$HOME/.inputrc" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
backup_and_link "$SCRIPT_DIR/misc/profile" "$HOME/.profile" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
backup_and_link "$SCRIPT_DIR/misc/nanorc" "$HOME/.nanorc" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"

# Link termux configs
if [ -d "$HOME/.termux" ]; then
    backup_and_link "$SCRIPT_DIR/termux/colors.properties" "$HOME/.termux/colors.properties" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
    backup_and_link "$SCRIPT_DIR/termux/termux.properties" "$HOME/.termux/termux.properties" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
else
    echo "Creating ~/.termux directory"
    mkdir -p "$HOME/.termux"
    backup_and_link "$SCRIPT_DIR/termux/colors.properties" "$HOME/.termux/colors.properties" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
    backup_and_link "$SCRIPT_DIR/termux/termux.properties" "$HOME/.termux/termux.properties" "$HOME/.backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
fi

echo "Dotfiles installation complete!"
echo "Please restart your shell or run 'source ~/.bashrc' to apply changes."
echo "For Termux, you may need to restart the app for color changes to take effect."