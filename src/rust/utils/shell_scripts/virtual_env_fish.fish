function activate
    set -g _OLD_VIRTUAL_PATH $PATH
    set -gx PATH "python_modules/bin" $PATH
    set -gx VIRTUAL_ENV "python_modules"
    set -gx PS1 "($VIRTUAL_ENV) $PS1"
end

activate
