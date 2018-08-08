{ config, lib, ... }:

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
      GDK_SCALE = "2";
      GDK_DPI_SCALE = "0.5";
    };
    services.xserver.dpi = 96 * cfg.scale;
  };
}
