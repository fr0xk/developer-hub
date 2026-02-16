# ~/.zshrc - Pragmatic Anti-Capitalist Shell
#
# Philosophy: Longevity, Efficiency, Self-sufficiency.
# "Tools should serve the user, not the other way around."

# --- History & Privacy ---
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# --- Environment ---
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='hx'
export VISUAL='hx'
export PAGER='bat'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- SSH Agent (Robust) ---
# Ensure SSH agent is running for git operations
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -e "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi
# Add key if not present (silently)
ssh-add -l >/dev/null 2>&1 || ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null

# --- Modern Tools Integration ---
# Initialize zoxide (smarter cd) if installed
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# Initialize starship (minimal, fast prompt) if installed, else fallback
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
else
    # Minimal pragmatic prompt: user@host dir [git-branch] $
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' [%b]'
    setopt PROMPT_SUBST
    PROMPT='fr0xk@eula47 %1~${vcs_info_msg_0_} $ '
fi

# --- Aliases (Efficiency) ---
# File listing
if command -v eza >/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias tree='eza --tree --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -la'
fi

# File reading
if command -v bat >/dev/null; then
    alias cat='bat -p' # plain style
    alias less='bat'
fi

# Grep
if command -v rg >/dev/null; then
    alias grep='rg'
else
    alias grep='grep --color=auto'
fi

# Editor
if command -v hx >/dev/null; then
    alias vi='hx'
    alias vim='hx'
    alias nano='hx'
else
    # Fallback to vim or nano if hx is missing
    command -v vim >/dev/null && alias vi='vim'
    command -v nano >/dev/null && alias vi='nano'
fi

# Git shortcuts
if command -v git >/dev/null; then
    alias g='git'
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit -m'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate --all'
    alias gd='git diff'
fi

# --- Maintenance Functions ---

# Unified update function
maintain() {
    echo "🛠️  Starting System Maintenance..."
    
    echo "\n📦 Updating System Packages..."
    pkg update -y && pkg upgrade -y
    
    # Check for language-specific updates if managers exist
    if command -v rustup >/dev/null; then
        echo "\n🦀 Updating Rust..."
        rustup update
    fi
    
    if command -v npm >/dev/null; then
        echo "\n📜 Updating Global NPM Packages..."
        npm update -g
    fi
    
    # Run the user's custom maintenance script if it exists
    if [ -f "$HOME/.local/bin/long-term-maintenance.sh" ]; then
        echo "\n🔍 Running Health Checks..."
        bash "$HOME/.local/bin/long-term-maintenance.sh"
    fi
    
    echo "\n✨ Maintenance Complete. System is consistent."
}

# Cleanup function (optimization)
clean() {
    echo "🧹 Cleaning up system junk..."
    
    # Package manager cleanup
    pkg clean
    pkg autoclean
    
    # Cache cleanup
    rm -rf ~/.cache/pip
    rm -rf ~/.npm/_cacache
    
    # Cargo cleanup (if installed)
    if command -v cargo >/dev/null; then
        rm -rf ~/.cargo/registry/src
    fi

    echo "✨ System optimized."
}

# Make scripts executable automatically
chmod +x $HOME/.local/bin/*.sh 2>/dev/null
