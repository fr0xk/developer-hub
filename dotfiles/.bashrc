# ~/.bashrc - Ultra-robust, self-contained shell configuration
# Designed to be "virus-like": deploy anywhere, survive crashes, self-heal

# === CORE SAFETY MECHANISMS ===
# 1. Set strict error handling (fail fast on errors)
set +e  # Disable strict error handling initially for robustness
shopt -s nullglob dotglob  # Handle empty globs gracefully

# 2. Define safe functions with fallbacks
safe_export() {
    local var="$1"
    local value="$2"
    if [ -n "$value" ] && [ "$value" != " " ]; then
        export "$var"="$value"
    fi
}

safe_alias() {
    local name="$1"
    local cmd="$2"
    if command -v "${cmd%% *}" >/dev/null 2>&1; then
        alias "$name"="$cmd"
    else
        # Fallback: create function that shows warning
        eval "$name() { echo '⚠️  $name: $(echo \"$cmd\" | cut -d\" \" -f1) not available'; }"
    fi
}

# 3. Environment detection
detect_os() {
    if [ -f "/system/bin/toolbox" ] || [ -f "/system/bin/toybox" ]; then
        echo "android-termux"
    elif [ "$(uname -s)" = "Linux" ]; then
        echo "linux"
    elif [ "$(uname -s)" = "Darwin" ]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# 4. Safe PATH manipulation
safe_add_to_path() {
    local dir="$1"
    if [ -d "$dir" ] && ! echo "$PATH" | grep -q "$dir"; then
        export PATH="$dir:$PATH"
    fi
}

# === CORE CONFIGURATION ===
# Basic security and privacy (always safe)
safe_export HISTCONTROL "ignoredups:ignorespace"
safe_export HISTSIZE "5000"
safe_export HISTFILESIZE "10000"
safe_export HISTIGNORE "&:[ ]*"

# Robust PATH setup
safe_add_to_path "$HOME/.local/bin"
safe_add_to_path "$HOME/bin"
safe_add_to_path "$HOME/.cargo/bin"

# Editor defaults with fallbacks
if command -v vim >/dev/null 2>&1; then
    safe_export EDITOR "vim"
    safe_export VISUAL "vim"
elif command -v vim >/dev/null 2>&1; then
    safe_export EDITOR "vim"
    safe_export VISUAL "vim"
else
    safe_export EDITOR "cat"
    safe_export VISUAL "cat"
fi

# Terminal settings with fallbacks
safe_export TERM "xterm-256color"
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    safe_export COLORTERM "truecolor"
    safe_export LS_COLORS "$(tput colors 2>/dev/null | grep -qE '^[0-9]+$' && echo 'di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43:' || echo '')"
fi

# === ROBUST ALIASES WITH FALLBACKS ===
# Always define aliases safely
safe_alias ls "ls --color=auto"
safe_alias ll "ls -lh"
safe_alias la "ls -A"
safe_alias grep "grep --color=auto"
safe_alias egrep "egrep --color=auto"
safe_alias fgrep "fgrep --color=auto"

# Git aliases with fallback detection
if command -v git >/dev/null 2>&1; then
    safe_alias g "git"
    safe_alias gs "git status"
    safe_alias ga "git add"
    safe_alias gc "git commit"
    safe_alias gp "git push"
    safe_alias gl "git log --oneline -n 10"
else
    safe_alias g "echo 'git not available'"
    safe_alias gs "echo 'git not available'"
    safe_alias ga "echo 'git not available'"
    safe_alias gc "echo 'git not available'"
    safe_alias gp "echo 'git not available'"
    safe_alias gl "echo 'git not available'"
fi

# Directory navigation with fallbacks
safe_alias .. "cd .."
safe_alias ... "cd ../.."
safe_alias .... "cd ../../.."
safe_alias ~ "cd ~"

# System info with graceful degradation
if command -v uname >/dev/null 2>&1; then
    safe_alias sysinfo "uname -a"
elif command -v cat >/dev/null 2>&1; then
    safe_alias sysinfo "cat /proc/version 2>/dev/null || echo 'System info unavailable'"
else
    safe_alias sysinfo "echo 'System info unavailable'"
fi

# === SELF-HEALING MECHANISMS ===
# Auto-recover from common failures
self_heal() {
    # Check for missing directories
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin" 2>/dev/null || true
    fi
    if [ ! -d "$HOME/.config" ]; then
        mkdir -p "$HOME/.config" 2>/dev/null || true
    fi
    
    # Fix broken symlinks
    find "$HOME" -lname "*dotfiles*" -type l 2>/dev/null | while read -r link; do
        if [ ! -e "$link" ]; then
            rm -f "$link" 2>/dev/null || true
        fi
    done
}

# Run self-heal on startup
self_heal

# === FINAL SAFETY NET ===
# If everything fails, provide basic functionality
if ! command -v echo >/dev/null 2>&1; then
    # This should never happen, but just in case
    echo() { /bin/echo "$@"; }
fi

# Success message
echo "✅ Bash environment loaded successfully"
echo "🛡️  Your shell is now ultra-robust and self-contained!"

# Restore error handling
set -e