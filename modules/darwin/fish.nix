{ config, lib, ... }:

with lib;

let
  cfg = config.programs.fish;
in

{
  config = mkIf cfg.enable {
    # Hack to fix PATH, see https://github.com/LnL7/nix-darwin/issues/122#issuecomment-829010570
    environment.etc."fish/nixos-env-preinit.fish".text = mkMerge [
      (mkBefore ''
        set -l _PATH $PATH
      '')
      (mkAfter ''
        for p in $PATH
           if not contains -- $p $_PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin
              set -ag fish_user_paths $p
           end
        end
        set -el _PATH
      '')
    ];
  };
}
