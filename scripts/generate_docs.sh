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
    RUST_PROJECTS=(
        "$PROJECT_ROOT/rust/offline-handbook"
        "$PROJECT_ROOT/rust/templates"
    )
    for project_path in "${RUST_PROJECTS[@]}"; do
        if [ -f "$project_path/Cargo.toml" ]; then
            PROJECT_NAME=$(basename "$project_path")
            echo "  -> Generating docs for $PROJECT_NAME..."
            cargo doc --no-deps --manifest-path "$project_path/Cargo.toml" --target-dir "$PROJECT_ROOT/docs/rust/$PROJECT_NAME"
        fi
    done
fi

# Python docs (using pdoc)
if command -v pdoc &> /dev/null; then
    echo "[*] Generating Python docs (using pdoc)..."
    # pdoc can generate for a module or a package directly.
    # We'll target the top-level python directory, assuming it contains discoverable modules/packages.
    # The output will be in $PROJECT_ROOT/docs/python/<module_name> or $PROJECT_ROOT/docs/python/<package_name>
    mkdir -p "$PROJECT_ROOT/docs/python" # Ensure target directory exists
    pdoc "$PROJECT_ROOT/python/" -o "$PROJECT_ROOT/docs/python"
else
    echo "[!] pdoc not found, skipping Python API docs."
fi

echo "Documentation updated in docs/ folder."