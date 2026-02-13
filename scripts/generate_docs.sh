#!/bin/bash
# Documentation Generation Script

echo "Generating Documentation..."

# Rust docs
if command -v cargo &> /dev/null; then
    cd src/rust/offline-handbook && cargo doc --no-deps --target-dir ../../../docs/rust
    cd ../../..
fi

# Python docs (example using pdoc)
if command -v pdoc &> /dev/null; then
    pdoc src/python -o docs/python
else
    echo "pdoc not found, skipping Python docs generation."
fi

echo "Documentation updated in docs/ folder."
