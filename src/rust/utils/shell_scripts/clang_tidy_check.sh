#!/bin/sh














if [ $
  echo "Usage: $0 <file1> [file2] ..."
  exit 1
fi

CHECKS="*,clang-analyzer-*"
WARNINGS_AS_ERRORS="clang-analyzer-*"
FIX_OPTION="-fix"

for file in "$@"; do
  if [ -f "$file" ]; then
    echo "Running clang-tidy on $file"
    clang-tidy "$file" --checks="$CHECKS" --warnings-as-errors="$WARNINGS_AS_ERRORS" \
      $FIX_OPTION
  else
    echo "File $file does not exist or is not a regular file."
  fi
done
