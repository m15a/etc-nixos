set -q __etc_fish_conf_d_symbols_sourced
or if status is-login
    function __set_U_if_undef; set -q $argv[1]; or set -U $argv; end

    __set_U_if_undef pure_symbol_prompt 󰣐
    __set_U_if_undef pure_symbol_reverse_prompt 
    __set_U_if_undef pure_symbol_virtualenv_prefix " "
    __set_U_if_undef pure_symbol_nixdevshell_prefix "󱄅 "

    functions -e __set_U_if_undef
end

set -g __etc_fish_conf_d_symbols_sourced
