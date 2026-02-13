# Path
for d in "$HOME/.local/bin" "$HOME/.cargo/bin" "/data/data/com.termux/files/usr/bin"; do
  [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH" ;; esac
done
export PATH

# Editor
export EDITOR_CMD="hx"
export EDITOR="$EDITOR_CMD"
export VISUAL="$EDITOR_CMD"

# History
export HISTFILE="$HOME/.local/share/bash/history"
export HISTSIZE=1000
export HISTCONTROL=ignoredups
mkdir -p "${HISTFILE%/*}"