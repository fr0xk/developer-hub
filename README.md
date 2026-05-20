# Developer Hub

A minimalist, suckless toolkit and environment configuration for developers, optimized for Termux and Linux.

## 📂 Project Structure

- `dotfiles/`: Core configuration files (bash, zsh, vim, tmux, etc.).
- `scripts/`: Collection of automation tools (Python, Go, Shell).
- `templates/`: Project templates and utility modules (Rust, etc.).
- `backups/`: System package lists and configuration backups.
- `projects/`: larger standalone projects.
- `setup.sh`: The main, robust entry point for syncing the environment.

## 🚀 Getting Started

To sync your environment with this hub:

```bash
./setup.sh
```

The setup script is designed to be "self-healing" and safe. It will create backups of any existing files it replaces in `~/.dotfiles_backup_<timestamp>`.

## 🛠️ Usage

### Scripts
All tools in `scripts/` are automatically made executable by `setup.sh`. You can run them directly or add `scripts/` to your PATH.

### Templates
Use the files in `templates/` as a starting point for new projects.

## 🛡️ Robustness
- **Non-destructive**: Always creates backups before replacing files.
- **Environment Aware**: Automatically detects if you are in Termux or a standard Linux environment.
- **Symlink Based**: Uses symlinks so local changes to the repo are reflected immediately in your home directory.

---
*Stay efficient. Stay minimal.*
