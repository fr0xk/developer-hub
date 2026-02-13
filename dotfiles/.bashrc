# ~/.bashrc

# Launch Fish if available
if command -v fish >/dev/null 2>&1 && [ -z "$BASH_EXECUTION_STRING" ]; then
  case "$(ps -o comm= -p $PPID)" in
    fish) ;;  # Already running fish as parent
    *) exec fish ;;
  esac
fi

bind " \"\e[Z\": backward-word"
bind "\"\e[Z\": backward-char"
