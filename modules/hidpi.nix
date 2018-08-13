{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environment.hidpi;
in

{
  options = {
    environment.hidpi.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        When enabled, use <option>hidpi.scale</option> as DPI scaling factor.
      '';
    };

    environment.hidpi.scale = mkOption {
      type = types.int;
      default = 2;
      description = ''
        DPI scaling factor.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.earlyVconsoleSetup = true;

    i18n.consoleFont = "latarcyrheb-sun32";

    environment.variables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = toString cfg.scale;
      GDK_DPI_SCALE = toString (1.0 / cfg.scale);
    };

    services.xserver.dpi = 96 * cfg.scale;

    services.xserver.displayManager.sessionCommands = let
      xresources = pkgs.writeText "Xresources" ''
        Xcursor.size: ${toString (24 * cfg.scale)}
      '';
    in ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xresources}
    '';
  };
}
