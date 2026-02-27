# ~/.zshrc - Unified minimal configuration inheriting from bashrc and fish

# === CORE ENVIRONMENT ===
# Privacy and security (from bashrc)
export HISTCONTROL=ignoredups:ignorespace
export HISTSIZE=5000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# PATH setup (combined from bashrc + fish)
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$HOME/go/bin:/data/data/com.termux/files/usr/bin"

# Editor and pager (from bashrc)
export EDITOR=vim
export PAGER=less
export VISUAL=vim

# Security hardening
unset TMOUT

# === SSH AGENT INTEGRATION === (from fish)
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -c)" >/dev/null
fi

if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# === VCS INFO FOR GIT BRANCH ===
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{green}[%b]%f'
zstyle ':vcs_info:git:*' actionformats ' %F{green}[%b|%a]%f'
precmd() { vcs_info }

# === MINIMAL ALIASES === (from bashrc, kept minimal)
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias top='htop'
alias df='df -h'
alias du='du -h'

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -n 20'

alias vi='vim'
alias vim='vim -u NONE'

# === LAMBDA PROMPT WITH FISH AESTHETIC ===
# λ:~/path [branch] - inheriting Fish colors
setopt PROMPT_SUBST
PROMPT='%F{default}λ:%f%F{blue}%~%f${vcs_info_msg_0_} '