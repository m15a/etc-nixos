function __my_fish_prompt_umask \
    -d "Helper function for fish_prompt to show current umask unless 0077"

    if [ (umask) != 0077 ]
        set_color normal
        set_color brred --bold
        echo -n (umask)
        set_color normal
        true
    else
        false
    end
end
