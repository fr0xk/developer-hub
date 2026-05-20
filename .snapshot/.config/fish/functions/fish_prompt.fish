# Custom Fish prompt function
# This file is automatically loaded by Fish as a function

function fish_prompt
    set_color yellow
    echo -n "fr0xk"
    set_color normal
    echo -n "@"
    set_color green
    echo -n "eula47"
    set_color normal
    echo -n ":"
    set_color blue
    echo -n (pwd | sed "s|$HOME|~|")
    set_color normal
    echo -n " \$ "
end