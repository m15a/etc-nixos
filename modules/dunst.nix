{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dunst;
in

{
  options = {
    programs.dunst = {
      enable = mkEnableOption "dunst";

      package = mkOption {
        type        = types.package;
        default     = pkgs.dunst;
        defaultText = "pkgs.dunst";
        example     = "pkgs.dunst";
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
      after = [ "graphical-session.target" ];

      script = let
        args = optionalString (! isNull cfg.configFile) " -conf ${cfg.configFile}";
      in ''
        ${cfg.package}/bin/dunst${args}
      '';

      serviceConfig.Restart = "always";
    };
  };
}
