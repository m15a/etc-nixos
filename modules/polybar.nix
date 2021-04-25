{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.polybar;
in

{
  options = {
    services.polybar = {
      enable = mkEnableOption "polybar";

      package = mkOption {
        type        = types.package;
        default     = pkgs.polybar;
        defaultText = "pkgs.polybar";
        example     = literalExample "pkgs.polybar";
        description = ''
          polybar package to use.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = null;
        example     = "${cfg.package}/share/doc/polybar/config";
        description = ''
          Path to the polybar configuration file.
          If null, $XDG_CONFIG_HOME/polybar/config will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.polybar = {
      description = "polybar service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = let
          arg = "-c ${cfg.configFile}";
          inherit (config.environment.variables)
          XCURSOR_SIZE
          GDK_SCALE
          GDK_DPI_SCALE;
        in concatStringsSep " " ([
          "${pkgs.coreutils}/bin/env"
          "XCURSOR_SIZE=${XCURSOR_SIZE}"
          "GDK_SCALE=${GDK_SCALE}"
          "GDK_DPI_SCALE=${GDK_DPI_SCALE}"
          "${cfg.package}/bin/polybar"
        ] ++ optional (!isNull cfg.configFile) arg ++ [
          "top"
        ]);
        Restart = "always";
      };
    };
  };
}
