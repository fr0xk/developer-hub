# Unixporn Light Theme Dotfiles

This directory contains a carefully curated collection of configuration files designed for Unixporn enthusiasts who prefer light themes. The setup aims to provide a clean, minimalist, and aesthetically pleasing terminal environment.

## Features

- **Light Theme Consistency**: All configurations use a consistent light theme across shells and applications
- **Minimalist Design**: Following Unixporn principles with clean, uncluttered interfaces
- **Cross-Shell Compatibility**: Consistent look and feel across Fish, Zsh, and Bash
- **Optimized Editors**: Light-themed configurations for Vim and Nano
- **Terminal Optimized**: Properly configured Tmux with light theme

## Included Configurations

### Shell Configurations
- **Fish Shell** (`config.fish`): Custom light-themed prompt with username@hostname:path format
- **Zsh** (`.zshrc`): Matching prompt and color scheme to Fish
- **Bash** (`.bashrc`): Consistent light-themed prompt

### Editor Configurations
- **Vim** (`.vimrc`): Light-themed syntax highlighting and visual elements
- **Nano** (`.nanorc`): Light-themed interface

### Terminal Multiplexer
- **Tmux** (`.tmux.conf`): Clean light-themed status bar and borders

### Additional Configurations
- **Termux** settings: Light-themed colors and optimized key bindings
- **Input settings** (`.inputrc`): Consistent command-line behavior
- **Environment** (`.profile`): Light-themed application settings

## Installation

Run the installation script to symlink all configurations to your home directory:

```bash
./install.sh
```

This will:
1. Backup your existing configurations
2. Create symbolic links to the new configurations
3. Preserve your original files in a backup directory

## Post-Installation

After installation:
1. Restart your terminal or run `source ~/.bashrc`
2. For Termux, restart the app for color changes to take effect
3. The configurations will automatically apply to all new shell sessions

## Customization

Feel free to adjust colors and settings to match your personal preferences while maintaining the light theme aesthetic.