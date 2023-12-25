function __my_fish_prompt_userhost \
    -d "Helper function for fish_prompt to show user and host when using ssh"

    if status is-login
        set_color normal
        if [ -n "$SSH_CONNECTION" ]
            set_color $fish_color_user
            echo -n (whoami)
            set_color $fish_color_comment
            echo -n @
            set_color $fish_color_host
            echo -n (hostname -s)
        else
            set_color $fish_color_comment
            echo -n @
        end
        set_color normal
        true
    else
        false
    end
end

