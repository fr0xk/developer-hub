# ssh-agent management
export SSH_AUTH_SOCK="$HOME/.ssh/agent/ssh-auth-sock"

if [ ! -S "$SSH_AUTH_SOCK" ]; then
    mkdir -p ~/.ssh/agent
    eval "$(ssh-agent -a "$SSH_AUTH_SOCK")" > /dev/null
fi

# Add key if not already present
if ! ssh-add -l > /dev/null 2>&1; then
    ssh-add ~/.ssh/id_ed25519 > /dev/null 2>&1
fi

# Governor
if ! pgrep -x "governor" > /dev/null; then
    ~/governor > /dev/null 2>&1 &
fi