# ~/.bashrc - Unixporn Light Theme

# Set light theme colors
export PS1="\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ "
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Launch Fish if available
if command -v fish >/dev/null 2>&1 && [ -z "$BASH_EXECUTION_STRING" ]; then
  case "$(ps -o comm= -p $PPID)" in
    fish) ;;  # Already running fish as parent
    *) exec fish ;;
  esac
fi

bind " \"\e[Z\": backward-word"
bind "\"\e[Z\": backward-char"

# History settings
HISTSIZE=999
HISTFILESIZE=999

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
