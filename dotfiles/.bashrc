# ~/.bashrc - Anti-Capitalist Shell Configuration
#
# Philosophy: Longevity, Privacy, Self-sufficiency, Freedom
# Principles:
# - No telemetry or tracking (disabled auto-suggestions, no network calls)
# - Minimal dependencies (only essential tools)
# - FSF-approved licenses only
# - Designed to last decades, not quarters
# - User-controlled updates only

# Basic security and privacy
export HISTCONTROL=ignoredups:ignorespace
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTIGNORE="&:[ ]*"

# Essential PATH - prioritizing local, static binaries
export PATH="$HOME/.local/bin:$HOME/bin:/data/data/com.termux/files/usr/bin"

# Core aliases - minimal and functional
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# System monitoring (privacy-respecting)
alias top='htop'
alias df='df -h'
alias du='du -h'

# Git aliases - focused on decentralization
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -n 20'

# Privacy-first editing
alias vi='vim'
alias vim='vim -u NONE'  # Disable plugins for maximum control

# Anti-consumerist principles
# No auto-completion that might send data
# No fancy prompts that require constant updating
PS1='\u@\h:\w\$ '

# Security hardening
unset TMOUT  # Prevent automatic logout (user control)
export EDITOR=vim
export PAGER=less

echo "Anti-capitalist environment loaded"
echo "Principles: Longevity > Novelty, Privacy > Convenience, Freedom > Control"