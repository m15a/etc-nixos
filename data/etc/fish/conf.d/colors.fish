set -q __etc_fish_conf_d_colors_sourced
or if status is-login
    set -U fish_color_normal normal
    set -U fish_color_command --bold
    set -U fish_color_param cyan
    set -U fish_color_keyword magenta
    set -U fish_color_redirection yellow
    set -U fish_color_comment brblack
    set -U fish_color_error red
    set -U fish_color_escape yellow
    set -U fish_color_operator yellow
    set -U fish_color_end brblack
    set -U fish_color_quote brgreen
    set -U fish_color_autosuggestion brblack
    set -U fish_color_user white
    set -U fish_color_host white
    set -U fish_color_host_remote bryellow --bold
    set -U fish_color_valid_path --underline
    set -U fish_color_cwd blue --bold
    set -U fish_color_cwd_root brred --bold
    set -U fish_color_search_match --reverse
    set -U fish_color_cancel -r
    set -U fish_color_selection --reverse

    set -U fish_pager_color_prefix normal --bold
    set -U fish_pager_color_completion brblack
    set -U fish_pager_color_description yellow
    set -U fish_pager_color_progress black --bold --background=@accent@

    set -U my_fish_status_color_ok green
    set -U my_fish_status_color_error red
    set -U my_fish_status_color_warn yellow
end
set -g __etc_fish_conf_d_colors_sourced
