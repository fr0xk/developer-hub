#!/bin/sh

USER="fr0xk"
DISTRO="alpine"
STORAGE_PATH="$HOME/storage/shared"
BIND_PATH="/home/$USER/storage"

if command -v proot-distro >/dev/null 2>&1; then
  proot-distro login --user "$USER" "$DISTRO" --bind "$STORAGE_PATH:$BIND_PATH"
fi
