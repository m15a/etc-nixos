function __my_fish_prompt_pwd \
    -d "Helper function for fish_prompt to show current working directory"

    set_color normal
    set -l workdir (echo -n $PWD \
                    | command sed -e "s|^$HOME|~|" -e 's|^/private||' \
                    | string split "/")
    for elem in $workdir
        if [ $elem = "~" ]
            set_color $fish_color_operator
        else
            set_color $fish_color_cwd
        end
        echo -n $elem
        set_color $fish_color_comment
        echo -n "/"
    end
    set_color normal
end
