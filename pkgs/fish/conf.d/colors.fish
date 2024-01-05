set -q __etc_fish_conf_d_colors_sourced
or if status is-login
    function __set_U_if_undef; set -q $argv[1]; or set -U $argv; end

    # References:
    #   github:fish-shell/fish-shell/share/tools/web_config/themes/fish default.theme
    #   github:fish-shell/fish-shell/share/functions/fish_config_interactive.fish
    __set_U_if_undef fish_color_normal normal
    __set_U_if_undef fish_color_command magenta
    __set_U_if_undef fish_color_keyword cyan -i
    __set_U_if_undef fish_color_param normal
    __set_U_if_undef fish_color_option brmagenta
    __set_U_if_undef fish_color_redirection bryellow --bold
    __set_U_if_undef fish_color_comment brblack
    __set_U_if_undef fish_color_error red
    __set_U_if_undef fish_color_escape brred
    __set_U_if_undef fish_color_operator brcyan
    __set_U_if_undef fish_color_end white
    __set_U_if_undef fish_color_quote brgreen
    __set_U_if_undef fish_color_autosuggestion brblack
    __set_U_if_undef fish_color_user white
    __set_U_if_undef fish_color_host white
    __set_U_if_undef fish_color_host_remote yellow
    __set_U_if_undef fish_color_valid_path --underline
    __set_U_if_undef fish_color_status red
    __set_U_if_undef fish_color_cwd blue
    __set_U_if_undef fish_color_cwd_root red
    __set_U_if_undef fish_color_search_match --reverse
    __set_U_if_undef fish_color_selection --reverse
    __set_U_if_undef fish_color_cancel -r
    __set_U_if_undef fish_pager_color_prefix normal --bold
    __set_U_if_undef fish_pager_color_completion brblack
    __set_U_if_undef fish_pager_color_description bryellow -i
    __set_U_if_undef fish_pager_color_progress black --background=@accent@
    __set_U_if_undef fish_pager_color_selected_background -r
    __set_U_if_undef fish_color_history_current --bold

    # github:pure-fish/pure
    __set_U_if_undef pure_color_danger $fish_color_error
    __set_U_if_undef pure_color_dark black
    __set_U_if_undef pure_color_info @accent@
    __set_U_if_undef pure_color_light white
    __set_U_if_undef pure_color_mute brblack
    __set_U_if_undef pure_color_normal normal
    __set_U_if_undef pure_color_primary blue
    __set_U_if_undef pure_color_success green
    __set_U_if_undef pure_color_warning yellow

    # NOTE:
    #   mb: begin blinking
    #   md: begin bold
    #   me: end blinking/bold
    #   so: begin standout
    #   se: end standout
    #   us: begin underline
    #   ue: end underline
    __set_U_if_undef LESS_TERMCAP_mb (printf "\e[5m")
    __set_U_if_undef LESS_TERMCAP_md (printf "\e[1m")
    __set_U_if_undef LESS_TERMCAP_me (printf "\e[0m")
    __set_U_if_undef LESS_TERMCAP_so (printf "\e[38;5;@sel_fg_nr@;48;5;@accent_nr@m")
    __set_U_if_undef LESS_TERMCAP_se (printf "\e[0m")
    __set_U_if_undef LESS_TERMCAP_us (printf "\e[3;33m")
    __set_U_if_undef LESS_TERMCAP_ue (printf "\e[0m")

    functions -e __set_U_if_undef
end
set -g __etc_fish_conf_d_colors_sourced
