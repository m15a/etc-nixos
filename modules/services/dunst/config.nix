{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dunst;
  inherit (config.environment) colors hidpi;
in

{
  config = lib.mkIf cfg.enable {
    services.dunst.configFile = lib.mkDefault (
      pkgs.substituteAll (
        (lib.mapAttrs (c: c.hex) colors.theme)
        // rec {
          src = ./dunstrc;
          icon_theme = "Papirus";
          icon_path =
            let
              s = toString (24 * hidpi.scale);
              path = "${pkgs.papirus-icon-theme}/share/icons/${icon_theme}";
            in
            lib.concatStringsSep ":" (
              map (c: "${path}/${s}x${s}/${c}") [
                "status"
                "devices"
                "apps"
              ]
            );
          browser = "${pkgs.xdg_utils}/bin/xdg-open";
        }
      )
    );
  };
}
