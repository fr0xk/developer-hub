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

function smol
    if type -q llama-cli
        llama-cli -m storage/shared/Models/SmolLM3-Q4_K_M.gguf -t 2 -c 1024 --mlock --no-mmap --temp 0 --reasoning-budget 0 -st $argv
    end
end

function fish_prompt
    set_color yellow
    echo -n "λ "(pwd | sed "s|$HOME|~|")" : "
    set_color normal
end
