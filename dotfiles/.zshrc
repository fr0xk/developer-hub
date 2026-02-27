ZSH_STATIC_USER="fr0xk"
ZSH_STATIC_HOST="eula47"

export OS_TYPE="$(uname -s)"
export ARCH_TYPE="$(uname -m)"

HISTDIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
# mkdir -p "$HISTDIR"
HISTFILE="$HISTDIR/history"

HISTSIZE=5000
SAVEHIST=5000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS

path_add() {
    [ -d "$1" ] && path=("$1" $path)
}

path_add "$HOME/.local/bin"
path_add "$HOME/.cargo/bin"
path_add "$HOME/go/bin"

export PATH

autoload -U colors
colors

if [[ -n "$ZSH_STATIC_USER" && -n "$ZSH_STATIC_HOST" ]]; then
    PROMPT="%F{yellow}${ZSH_STATIC_USER}%f@%F{green}${ZSH_STATIC_HOST}%f:%F{blue}%~%f %(#.%F{red}#%f.$) "
else
    PROMPT="%F{yellow}%n%f@%F{green}%m%f:%F{blue}%~%f %(#.%F{red}#%f.$) "
fi

if [[ -z "$SSH_AUTH_SOCK" ]]; then
    if [[ -f "$HOME/.ssh/agent_env" ]]; then
        source "$HOME/.ssh/agent_env" >/dev/null
    fi
fi

if ! ssh-add -l >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
    {
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
        echo "export SSH_AGENT_PID=$SSH_AGENT_PID"
    } > "$HOME/.ssh/agent_env"
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
fi

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt CORRECT

autoload -Uz compinit
compinit

case "$OS_TYPE" in
    Linux)
        alias ls='ls --color=auto'
        ;;
    Darwin)
        alias ls='ls -G'
        ;;
esac

umask 022
