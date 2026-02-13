#!/bin/sh


HOOK_DIR=".git/hooks"
PRE_COMMIT_HOOK="$HOOK_DIR/pre-commit"

echo "Installing pre-commit hook..."

cat >"$PRE_COMMIT_HOOK" <<'EOF'




REPO_ROOT=$(git rev-parse --show-toplevel)

echo "📝 Updating README.md with latest project structure..."
python3 "$REPO_ROOT/python/generate_readme.py"


git add "$REPO_ROOT/README.md"
EOF

chmod +x "$PRE_COMMIT_HOOK"
echo "✅ Hook installed! README.md will auto-update on every commit."
