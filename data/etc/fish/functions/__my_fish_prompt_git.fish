function __my_fish_prompt_git \
    -d "Helper function for fish_prompt to show git branch in git repo"

    if __fish_is_git_repository
        echo -n $my_fish_symbol_git(fish_git_prompt | command sed 's|^ (\(.*\))$|\1|')
        true
    else
        false
    end
end

