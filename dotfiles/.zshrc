# ~/.zshrc - Pragmatic & Minimal Shell
#
# Philosophy: Depend on standard tools. Extras are optional enhancements.

# --- History ---
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --- Environment ---
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='vi'  # Default to standard vi
export VISUAL='vi'

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

# Override with Starship only if explicitly installed and preferred
# if command -v starship >/dev/null; then eval "$(starship init zsh)"; fi

# --- Simple Aliases (Standard tools first) ---
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias grep='grep --color=auto'

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
