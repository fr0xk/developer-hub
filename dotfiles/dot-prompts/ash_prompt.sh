# Ash/Dash Prompt Customization

# ANSI Color Codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

get_prompt() {
  exit_code=$?

  # Path
  _pwd="${PWD#$HOME}"
  [ "$_pwd" != "$PWD" ] && _pwd="~$_pwd"

  # Git
  _git=""
  if git rev-parse --git-dir >/dev/null 2>&1; then
    _branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    _git=" (${_branch})"
  fi

  # Status color for lambda
  _color=$GREEN
  [ $exit_code -ne 0 ] && _color=$RED

  printf "${GREEN}fr0xk${NC}@${CYAN}eula47${NC} ${BLUE}%s${NC}${YELLOW}%s${NC} ${_color}λ${NC} " "$_pwd" "$_git"
}

# For shells that support command substitution in PS1 (like busybox ash)
# We need to escape the $ for the initial assignment
if [ -n "$ASH_VERSION" ] || [ -n "$BUSYBOX_VERSION" ]; then
  export PS1='$(get_prompt)'
else
  # Fallback for dash: update on cd
  set_ash_prompt() {
    PS1=$(get_prompt)
  }
  alias cd='cd && set_ash_prompt'
  set_ash_prompt
fi