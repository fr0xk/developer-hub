# Unixporn Light Theme .zshrc

# Enable colors
autoload -U colors && colors

# Light theme colors for zsh
export LS_COLORS="di=34:fi=00:ln=36:pi=33:so=35:bd=35:cd=35:or=00:mi=00:su=31:sg=32:tw=36:ow=34"

# Prompt configuration to match fish
PROMPT="%F{yellow}%n%f@%F{green}%m%f:%F{blue}%~%f \$ "

# History settings
HISTSIZE=999
SAVEHIST=999
HISTFILE=~/.zsh_history

# Set up PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Enable auto-suggestions with light theme
if [ -f $HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # Set autosuggestion color to match light theme
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# Enable completion
autoload -U compinit; compinit

# SSH agent setup
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh/agent.env
fi
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    eval $(ssh-agent -s) > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi