function fish_prompt
    set -l last_pipestatus $pipestatus

    echo (string join " " (__my_fish_prompt_userhost) \
                          (__my_fish_prompt_pwd) \
                          (__my_fish_prompt_git))

    echo -n (string join " " (__my_fish_prompt_nixshell) \
                             (__my_fish_prompt_pythonvenv) \
                             (__my_fish_prompt_umask))
    __my_fish_prompt_pipestatus $last_pipestatus
    echo -n " "
end
