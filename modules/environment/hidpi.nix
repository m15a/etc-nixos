# Extra settings for HiDPI displays.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.environment.hidpi;
in

{
  options = {
    environment.hidpi.enable = lib.mkEnableOption "HiDPI";
    environment.hidpi.scale = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = ''
        HiDPI scaling factor. If <option>environment.hidpi.enable</option> is
        <code>false</code>, <option>environment.hidpi.scale</option> is set to 1.
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
      environment.hidpi.scale = lib.mkDefault 1;
    })
  ];
}
