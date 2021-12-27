function __my_fish_prompt_pipestatus \
    -d "Helper function for fish_prompt to show a series of pipe status by colorized prompts"

    set_color normal
    for _status in $argv
        if [ $_status -eq 0 ]
            set_color $my_fish_status_color_ok
        else
            set_color $my_fish_status_color_error
            echo -n $_status
        end
        echo -n $my_fish_symbol_prompt
    end
    set_color normal
end
