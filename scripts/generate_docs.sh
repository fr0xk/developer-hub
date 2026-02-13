#!/bin/bash
# Documentation Generation Script (Run from project root)

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Generating Documentation in $PROJECT_ROOT..."

# Update README contents lists
if [ -f "$PROJECT_ROOT/scripts/update_readmes.py" ]; then
    echo "[*] Updating README files..."
    python3 "$PROJECT_ROOT/scripts/update_readmes.py"
fi

# Rust docs
if command -v cargo &> /dev/null; then
    echo "[*] Generating Rust docs..."
    cd "$PROJECT_ROOT/rust/offline-handbook" && cargo doc --no-deps --target-dir "$PROJECT_ROOT/docs/rust"
fi

# Python docs
if command -v pdoc &> /dev/null; then
    echo "[*] Generating Python docs..."
    pdoc "$PROJECT_ROOT/python/" -o "$PROJECT_ROOT/docs/python"
else
    echo "[!] pdoc not found, skipping Python docs."
fi

echo "Documentation updated in docs/ folder."
