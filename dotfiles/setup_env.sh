#!/bin/bash
# setup_env.sh - Robust Environment Setup for Termux
#
# Philosophy: Idempotency, Robustness, Self-sufficiency.
# "Ensure the environment is ready before work begins."

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting Robust Environment Setup..."

# --- 1. Dependency Management ---
REQUIRED_PACKAGES=(
    "zsh"
    "git"
    "openssh"
)

# Optional "quality of life" tools - not strictly required for the environment
OPTIONAL_TOOLS=(
    "eza"
    "bat"
    "starship"
    "zoxide"
    "helix"
    "ripgrep"
)

echo "📦 Checking and installing essential dependencies..."
pkg update -y

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1 && ! pkg list-installed | grep -q "^$pkg/"; then
        echo "  - Installing $pkg..."
        pkg install -y "$pkg"
    else
        echo "  - $pkg is already installed."
    fi
done

echo "🔍 Optional tools (install manually if desired: ${OPTIONAL_TOOLS[*]})"

# --- 2. Dotfiles Sync (Symlinking) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SOURCE="$SCRIPT_DIR/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

echo "🔗 Syncing dotfiles..."
if [ -L "$ZSHRC_TARGET" ] && [ "$(readlink "$ZSHRC_TARGET")" == "$ZSHRC_SOURCE" ]; then
    echo "  - .zshrc is already correctly linked."
else
    if [ -f "$ZSHRC_TARGET" ]; then
        BACKUP="$HOME/.zshrc.backup.$(date +%s)"
        echo "  - Backing up existing .zshrc to $BACKUP"
        mv "$ZSHRC_TARGET" "$BACKUP"
    fi
    echo "  - Linking $ZSHRC_SOURCE -> $ZSHRC_TARGET"
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
fi

# --- 3. SSH Agent & Git Config ---
echo "🔑 Configuring SSH and Git..."

# Ensure SSH key exists
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    echo "  - ⚠️ SSH key not found at $SSH_KEY. Please generate one with 'ssh-keygen -t ed25519'."
    # Don't fail, just warn.
else
    echo "  - SSH key found."
fi

# Ensure correct permissions for .ssh
chmod 700 "$HOME/.ssh"
chmod 600 "$SSH_KEY" 2>/dev/null

# Check if SSH Agent is running (simple check)
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "  - SSH Agent not running in current session. It will be started by .zshrc."
else
    echo "  - SSH Agent is running."
    # Add key if not present
    ssh-add -l >/dev/null 2>&1 || ssh-add "$SSH_KEY" 2>/dev/null
fi

# Git Remote Check
REPO_DIR="$HOME/workspace/developer-hub"
if [ -d "$REPO_DIR/.git" ]; then
    CURRENT_REMOTE=$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || echo "")
    DESIRED_REMOTE="git@github.com:fr0xk/developer-hub.git"
    
    if [ "$CURRENT_REMOTE" != "$DESIRED_REMOTE" ]; then
        echo "  - Updating git remote to SSH: $DESIRED_REMOTE"
        git -C "$REPO_DIR" remote set-url origin "$DESIRED_REMOTE"
    else
        echo "  - Git remote is correctly set to SSH."
    fi
fi

echo "✅ Setup Complete! Please restart your shell or run 'source ~/.zshrc'."
