/*
 * Extra settings for HiDPI displays.
 */
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.video.hidpi;
in

{
  options = {
    hardware.video.hidpi.scale = mkOption {
      type = types.int;
      default = 2;
      description = ''
        HiDPI scaling factor. If <option>hardware.video.hidpi.enable</option> is
        false, <option>hardware.video.hidpi.scale</option> is set to 1.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.variables = {
        XCURSOR_SIZE = toString (24 * cfg.scale);
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        GDK_SCALE = toString cfg.scale;
        GDK_DPI_SCALE = toString (1.0 / cfg.scale);
      };

      services.xserver.dpi = 96 * cfg.scale;
    })

    (mkIf (!cfg.enable) {
      hardware.video.hidpi.scale = mkDefault 1;
    })
  ];
}
