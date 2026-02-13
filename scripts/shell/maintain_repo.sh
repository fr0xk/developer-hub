#!/bin/sh



echo "⚙️  Running Perpetual Maintenance Protocols..."



YEAR=$(date +%Y)
if [ -f LICENSE ]; then
  
  sed -i "s/Copyright (c) [0-9]\{4\}/Copyright (c) $YEAR/" LICENSE
  
  sed -i "s/-[0-9]\{4\} /- $YEAR /" LICENSE
  echo "✅ License year updated to $YEAR."
fi



if command -v gofmt >/dev/null 2>&1; then
  echo "🧹 Formatting Go code..."
  find . -name "*.go" -not -path "*/vendor/*" -exec gofmt -w {} +
fi


if command -v clang-format >/dev/null 2>&1; then
  echo "🧹 Formatting C/C++ code..."
  find . -regex '.*\.\(c\|h\|cpp\|hpp\|cc\|cxx\)' -not -path "*/vendor/*" -exec clang-format -i {} +
fi


if command -v shfmt >/dev/null 2>&1; then
  echo "🧹 Formatting Shell scripts..."
  shfmt -l -w .
fi


echo "🗑️  Cleaning temporary files..."
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -name ".DS_Store" -delete
find . -name "*.bak" -delete
find . -name "*.swp" -delete


if [ -f python/generate_readme.py ]; then
  echo "📝 Refreshing README.md..."
  python3 python/generate_readme.py
fi

echo "✨ Repository maintenance complete."
