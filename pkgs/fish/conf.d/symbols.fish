set -q __etc_fish_conf_d_symbols_sourced
or if status is-login
   set -U my_fish_symbol_prompt ❯
   set -U my_fish_symbol_git_branch "󰘬 "
   set -U my_fish_symbol_nix " "
   set -U my_fish_symbol_python " "
end
set -g __etc_fish_conf_d_symbols_sourced
