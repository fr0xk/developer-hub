Light-themed dotfiles
Minimal configurations for shells, editors, and terminal tools.
Clean, aesthetic Unix environment setup.
Install with ./install.sh to symlink to home directory.

## Cleanup performed
- Removed duplicate `export EDITOR` and `export VISUAL` entries in `.zshrc`
- Streamlined editor setup: default to vim, fallback to nano only when vim is unavailable
- Synced current dotfiles from home directory to ensure consistency