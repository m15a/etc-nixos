{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.zathura;
  inherit (config.environment) colors;
in

{
  config = lib.mkIf cfg.enable {
    programs.zathura.configFile = lib.mkDefault (
      pkgs.substituteAll (
        (lib.mapAttrs (c: c.hex) colors.theme) // { src = ./zathurarc; }
      )
    );
  };
}
