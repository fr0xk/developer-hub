# Unixporn Light Theme Custom Prompt
# Unified prompt configuration for fish, bash, and zsh

# Define the custom prompt values
CUSTOM_USER="fr0xk"
CUSTOM_HOST="eula47"

# Function to set the prompt based on the current shell
set_custom_prompt() {
    case $1 in
        "bash")
            # Bash shell prompt
            export PS1="\[\033[01;33m\]$CUSTOM_USER@$CUSTOM_HOST\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ "
            ;;
        "zsh")
            # Zsh shell prompt
            PROMPT="%F{yellow}$CUSTOM_USER%f@%F{green}$CUSTOM_HOST%f:%F{blue}%~%f \$ "
            ;;
    esac
}