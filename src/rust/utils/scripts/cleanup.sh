#!/bin/sh

echo "[*] Cleaning history files..."
targets="
$HOME/.bash_history
$HOME/.zsh_history
$HOME/.python_history
$HOME/.lesshst
$HOME/.viminfo
$HOME/.ash_history
$HOME/.local/share/fish/fish_history
$HOME/.local/share/bash/history
$HOME/.config/fish/fish_history
"

for file in $targets; do
    if [ -f "$file" ]; then
        rm -f "$file" 2>/dev/null && echo "Done: $(basename "$file")" || echo "Failed: $(basename "$file") (Permission Denied)"
    fi
done

echo "[*] Searching for logs and artifacts..."

find . -mindepth 1 \( -type d \( -name "dist" -o -name "build" -o -name ".cache" -o -name "__pycache__" \) \
    -o -type f \( -name "*.tmp" -o -name "*.log" \) \) \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/go/pkg/*" \
    -exec rm -rf {} + 2>/dev/null

echo "Done: Build artifacts and log files."

