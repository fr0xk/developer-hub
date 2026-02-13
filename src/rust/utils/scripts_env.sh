
if [ -d "$HOME/scripts" ]; then
    case ":$PATH:" in
        *":$HOME/scripts:"*) ;;
        *) export PATH="$HOME/scripts:$PATH" ;;
    esac
fi
