{ config, lib, ... }:

with lib;

let
  cfg = config.programs.bash;
in

{
  config = mkIf cfg.enable {
    # Hack to load bashrc when nix-shell is impure, see https://github.com/LnL7/nix-darwin/pull/163
    environment.etc."bashrc".text = mkMerge [
      (mkBefore ''
        if test -n "$IN_NIX_SHELL"; then
            case "$IN_NIX_SHELL" in
                impure)
                    _IN_NIX_SHELL_IMPURE=yes
                    unset IN_NIX_SHELL
                    ;;
            esac
        fi
      '')
      (mkAfter ''
        if test -n "$_IN_NIX_SHELL_IMPURE"; then
            export IN_NIX_SHELL=impure
            unset _IN_NIX_SHELL_IMPURE
        fi
      '')
    ];
  };
}
