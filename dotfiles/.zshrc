# ~/.zshrc - Pragmatic & Minimal Shell
#
# Philosophy: Depend on standard tools. Extras are optional enhancements.

# --- Go Environment ---
# Set CGO_ENABLED=0 for static compilation by default
export CGO_ENABLED=0
export GOFLAGS="-tags netgo"

# --- History ---
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --- Environment ---
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='vim'  # Default to vim for intelligent autocomplete
export VISUAL='vim'

# --- SSH Agent (Essential for Git) ---
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -e "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add -l >/dev/null 2>&1 || ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null

# --- Simple Prompt (No extra tools required) ---
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' [%b]'
setopt PROMPT_SUBST
# Default simple prompt: user@host dir [git] $
PROMPT='fr0xk@eula47 %1~${vcs_info_msg_0_} $ '

# --- Intelligent Autocomplete (Built-in ZSH) ---
# Enable zsh's built-in completion system (works without extra packages)
mkdir -p ~/.zsh/cache 2>/dev/null

# Add Termux's completion functions to fpath
fpath=(/data/data/com.termux/files/usr/share/zsh/site-functions $fpath)

# Initialize completion system
autoload -Uz compinit
compinit -C -d ~/.zsh/cache/compdump 2>/dev/null || true

# Basic completion options
setopt COMPLETE_IN_WORD
setopt AUTO_MENU
setopt ALWAYS_LAST_PROMPT

# Simple completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _expand _complete _correct
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Directory completion enhancements
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Git completion (use built-in if available)
zstyle ':completion:*:*:git:*' script /data/data/com.termux/files/usr/share/zsh/site-functions/_git 2>/dev/null || true

# History-based completion
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes

# Basic file completion
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' verbose true

# Override with Starship only if explicitly installed and preferred
# if command -v starship >/dev/null; then eval "$(starship init zsh)"; fi

# --- Simple Aliases (Standard tools first) ---
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias grep='grep --color=auto'

# Editor setup - prefer vim, fallback to nano
# The default EDITOR/VISUAL are already set above
if ! command -v vim >/dev/null; then
    # Only set fallback to nano if vim is not available
    export EDITOR='nano'
    export VISUAL='nano'
    alias vi='nano'
    alias vim='nano'
    # If vim not available, create minimal vim-like experience
    mkdir -p ~/.vim 2>/dev/null
    touch ~/.vimrc 2>/dev/null
fi

# Optional: Use enhancements only if they exist
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first'
    alias ll='eza -l --git'
fi
if command -v bat >/dev/null; then
    alias cat='bat -p'
fi
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# Git shortcuts (Standard git)
alias g='git'
alias gs='git status'
alias gp='git push'

# --- Simple Maintenance ---
maintain() {
    echo "Updating system packages..."
    pkg update -y && pkg upgrade -y
}

# Cleanup
clean() {
    pkg clean
}

# Auto-executables
chmod +x $HOME/.local/bin/*.sh 2>/dev/null
