# Bash Prompt Customization

__git_ps1() {
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    echo -e " \033[0;33m($branch)\033[0m"
  fi
}

__shorten_pwd() {
  local full_path="${PWD/#$HOME/\~}"
  local IFS='/'
  read -ra parts <<<"$full_path"
  local length=${#parts[@]}

  if [ $length -le 4 ]; then
    echo "$full_path"
  else
    # Show first part, then ellipsis, then last two parts
    echo "${parts[0]}/.../${parts[$length - 2]}/${parts[$length - 1]}"
  fi
}

set_bash_prompt() {
  local last_status=$?
  local green="\[\033[0;32m\]"
  local cyan="\[\033[0;36m\]"
  local blue="\[\033[0;34m\]"
  local yellow="\[\033[0;33m\]"
  local red="\[\033[0;31m\]"
  local reset="\[\033[0m\]"

  local user_host="${green}fr0xk${reset}@${cyan}eula47${reset}"
  local pwd_shortened="${blue}$(__shorten_pwd)${reset}"

  local git_info=""
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    git_info=" ${yellow}($branch)${reset}"
  fi

  local symbol="${green}λ${reset}"
  if [ $last_status -ne 0 ]; then
    symbol="${red}λ${reset}"
  fi

  PS1="${user_host} ${pwd_shortened}${git_info} ${symbol} "
}

PROMPT_COMMAND=set_bash_prompt