# ~/.bashrc - Unixporn Light Theme

# Set light theme colors
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Source custom prompt
if [ -f "$HOME/.config/prompt/custom_prompt.sh" ]; then
    source "$HOME/.config/prompt/custom_prompt.sh"
    set_custom_prompt "bash"
fi

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
