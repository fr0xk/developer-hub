# Unixporn Light Theme config.fish

set -g fish_greeting ""
# Light theme colors for fish shell
set -g fish_color_normal black
set -g fish_color_command blue
set -g fish_color_quote yellow
set -g fish_color_redirection magenta
set -g fish_color_end red
set -g fish_color_error red
set -g fish_color_param green
set -g fish_color_comment cyan
set -g fish_color_match cyan
set -g fish_color_selection white--black
set -g fish_color_search_match cyan--white
set -g fish_color_operator purple
set -g fish_color_escape cyan
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_valid_path --underline
set -g fish_color_autosuggestion brightblack

set -g fish_history_file "$HOME/.local/share/fish/fish_history"
set -g fish_history_save_default 999
set -g fish_history_save_unmodified 500

set -gx PATH "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/go/bin" $PATH

# Clean light-themed prompt
function fish_prompt
    set_color yellow
    echo -n (whoami)
    set_color normal
    echo -n "@"
    set_color green
    echo -n (hostname | cut -d'.' -f1)
    set_color normal
    echo -n ":"
    set_color blue
    echo -n (pwd | sed "s|$HOME|~|")
    set_color normal
    echo -n " \$ "
end

# Start agent if not running and add key if not loaded
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) >/dev/null
end

if not ssh-add -l >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end
