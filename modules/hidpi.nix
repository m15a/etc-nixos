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
        When enabled, use <option>environment.hidpi.scale</option> as HiDPI
        scaling factor.
      '';
    };

    environment.hidpi.scale = mkOption {
      type = types.int;
      default = 2;
      description = ''
        HiDPI scaling factor. If <option>environment.hidpi.enable</option> is
        false, <option>environment.hidpi.scale</option> is set to 1.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      boot.loader.systemd-boot.consoleMode = "1";

      console.earlySetup = true;

      console.font = "latarcyrheb-sun32";

      environment.variables = {
        XCURSOR_SIZE = toString (24 * cfg.scale);
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        GDK_SCALE = toString cfg.scale;
        GDK_DPI_SCALE = toString (1.0 / cfg.scale);
      };

      services.xserver.dpi = 96 * cfg.scale;
    })

    (mkIf (!cfg.enable) {
      environment.hidpi.scale = mkDefault 1;
    })
  ];
}
