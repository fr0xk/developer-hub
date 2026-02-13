#!/bin/sh





echo "🔧 Normalizing permissions..."


find . -type d -not -path "./.git/*" -exec chmod 755 {} +


find . -type f -not -path "./.git/*" -exec chmod 644 {} +


find . -type f \( -name "*.sh" -o -name "*.fish" \) -not -path "./.git/*" -exec chmod +x {} +



find . -type f -not -path "./.git/*" -exec awk 'NR==1 && /^#!/ {print FILENAME}' {} + | xargs -r chmod +x


if [ -d ".git/hooks" ]; then
  chmod +x .git/hooks/*
fi

echo "✅ Permissions fixed. Ready to commit."
