# Minimal config.fish adhering to suckless principles

set -g fish_greeting ""
set -g fish_color_normal white
set -g fish_color_command cyan
set -g fish_color_user green
set -g fish_color_prompt blue

set -g fish_history_file "$HOME/.local/share/fish/fish_history"
set -g fish_history_save_default 999
set -g fish_history_save_unmodified 500

set -gx PATH "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/go/bin" $PATH

function fish_prompt
    set_color yellow
    echo -n "λ "(pwd | sed "s|$HOME|~|")" : "
    set_color normal
end

# Start agent if not running and add key if not loaded
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) >/dev/null
end

if not ssh-add -l >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end
