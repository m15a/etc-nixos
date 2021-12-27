function __my_fish_prompt_pythonvenv \
    -d "Helper function for fish_prompt to show python venv"

    if [ -n "$VIRTUAL_ENV" ]
        set_color normal
        set_color bryellow --bold
        echo -n $my_fish_symbol_python(command basename $VIRTUAL_ENV)
        set_color normal
        set -gx VIRTUAL_ENV_DISABLE_PROMPT true
        true
    else
        false
    end
end

