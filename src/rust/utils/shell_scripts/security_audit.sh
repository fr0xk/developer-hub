#!/bin/sh



EXIT_CODE=0

echo "🔒 Starting Monthly Security & Sanity Audit..."
echo "---------------------------------------------"


if command -v bandit >/dev/null 2>&1; then
  echo "🐍 Running Bandit (Python Security Analysis)..."
  
  bandit -r . -x ./test,./venv --exclude '*/test/*' -ll -ii
  if [ $? -ne 0 ]; then
    echo "❌ [CRITICAL] Bandit found security issues in Python code."
    EXIT_CODE=1
  else
    echo "✅ Python code looks safe."
  fi
else
  echo "⚠️ Bandit not found. Install with: pip install bandit"
fi

echo "---------------------------------------------"


echo "abc Running Basic Secret Pattern Scan..."

GREP_SECRETS=$(grep -rE "BEGIN RSA PRIVATE KEY|BEGIN OPENSSH PRIVATE KEY|AWS_ACCESS_KEY_ID|AIza[0-9A-Za-z\-_]{35}|ghp_[0-9a-zA-Z]{36}" . --exclude-dir=.git --exclude-dir=venv --exclude=security_audit.sh 2>/dev/null)

if [ ! -z "$GREP_SECRETS" ]; then
  echo "❌ [CRITICAL] Potential hardcoded secrets found:"
  echo "$GREP_SECRETS"
  EXIT_CODE=1
else
  echo "✅ No obvious hardcoded secrets found."
fi

echo "---------------------------------------------"


echo "💩 Checking for 'Bullshit' and Suspicious Patterns..."

grep -rE "TODO|FIXME|HACK|XXX|BUG" . --exclude-dir=.git --exclude-dir=venv --exclude=security_audit.sh | head -n 10


echo "🔎 Checking for suspicious shell execution patterns..."
SUSP_PATTERNS=$(grep -rE "eval\s+\\(|curl.*\|\s*sh|wget.*\|\s*sh|base64\s+-d.*\|\s*sh" . --exclude-dir=.git --exclude-dir=.config --exclude-dir=.emacs.d --exclude=security_audit.sh)
if [ ! -z "$SUSP_PATTERNS" ]; then
  echo "❌ [CRITICAL] Found suspicious execution patterns (eval, piping to sh):"
  echo "$SUSP_PATTERNS"
  EXIT_CODE=1
fi


echo "🔎 Checking for potential obfuscation (large base64 blocks)..."

OBFUSCATION=$(grep -rE "[A-Za-z0-9+/]{100,}" . --exclude-dir=.git --exclude-dir=venv --exclude=*.jpg --exclude=*.png --exclude=*.ttf --exclude=*.xz --exclude=security_audit.sh)
if [ ! -z "$OBFUSCATION" ]; then
  echo "⚠️ [WARNING] Potential obfuscated data found. Check logs."
  
fi

echo "---------------------------------------------"


echo "🐘 Checking for unexpectedly large files (>50MB)..."
find . -type f -size +50M -not -path "./.git/*" -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'

echo "---------------------------------------------"

if [ $EXIT_CODE -eq 0 ]; then
  echo "🎉 Audit Passed. No critical nightmares found."
else
  echo "🔥 Audit FAILED. Critical issues detected. Check the logs."
fi

exit $EXIT_CODE
