function __my_fish_prompt_nixshell \
    -d "Helper function for fish_prompt to indicate nix environment"

    if [ -n "$IN_NIX_SHELL" ]
        set_color normal
        set_color brblue --bold
        echo -n $my_fish_symbol_nix$IN_NIX_SHELL
        set_color normal
        true
    else
        false
    end
end

