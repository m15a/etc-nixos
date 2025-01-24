{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.rofi;
  inherit (config.environment) colors hidpi;
  terminal =
    if config.programs.alacritty.enable then
      "alacritty"
    else
      "rofi-sensible-terminal";
in

{
  config = lib.mkIf cfg.enable {
    programs.rofi.configFile = lib.mkDefault (
      pkgs.substituteAll (
        (lib.mapAttrs (c: c.hex) colors.theme)
        // {
          src = ./config.rasi;
          dpi = toString (96 * hidpi.scale);
          font = "monospace 13";
          inherit terminal;
        }
      )
    );
  };
}
