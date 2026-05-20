ZSH_STATIC_USER="fr0xk"
ZSH_STATIC_HOST="eula47"

export OS_TYPE="$(uname -s)"
export ARCH_TYPE="$(uname -m)"

HISTDIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
HISTFILE="$HISTDIR/history"
HISTSIZE=5000
SAVEHIST=5000

setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

path_add() { [ -d "$1" ] && path=("$1" $path); }
path_add "$HOME/.local/bin"
export PATH

autoload -U colors && colors

if [[ -n "$ZSH_STATIC_USER" && -n "$ZSH_STATIC_HOST" ]]; then
    PROMPT="%F{yellow}${ZSH_STATIC_USER}%f@%F{green}${ZSH_STATIC_HOST}%f:%F{white}%~%f %(#.%F{red}#%f.$) "
else
    PROMPT="%F{yellow}%n%f@%F{green}%m%f:%F{white}%~%f %(#.%F{red}#%f.$) "
fi

# Colorless ls
alias ls='ls -F'
unset LS_COLORS

setopt AUTO_CD INTERACTIVE_COMMENTS EXTENDED_GLOB CORRECT
autoload -Uz compinit && compinit

umask 022
