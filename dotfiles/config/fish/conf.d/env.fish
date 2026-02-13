# Fish environment and settings
set -g fish_greeting ""
set -gx PATH "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/go/bin" $PATH

# History settings
set -g fish_history_file "$HOME/.local/share/fish/fish_history"
set -g fish_history_save_default 999
set -g fish_history_save_unmodified 500
