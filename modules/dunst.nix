{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dunst;
in

{
  options = {
    services.dunst = {
      enable = mkEnableOption "dunst";

      package = mkOption {
        type        = types.package;
        default     = pkgs.dunst;
        defaultText = "pkgs.dunst";
        example     = literalExample "pkgs.dunst";
        description = ''
          dunst package to use.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = null;
        example     = "${cfg.package}/share/dunst/dunstrc";
        description = ''
          Path to the dunst configuration file.
          If null, $HOME/.config/dunst/dunstrc will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.dunst = {
      description = "dunst service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = let
          arg = "-conf ${cfg.configFile}";
        in concatStringsSep " " ([
          "${cfg.package}/bin/dunst"
        ] ++ optional (!isNull cfg.configFile) arg);
        Restart = "always";
      };
    };
  };
}
