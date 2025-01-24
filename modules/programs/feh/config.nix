{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.feh;
  inherit (config.environment.colors) theme;
in

{
  config = lib.mkIf cfg.enable {
    programs.feh.config.imageBg = theme.term_bg.hex;
  };
}
