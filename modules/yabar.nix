{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.yabar;
in

{
  options = {
    services.yabar = {
      enable = mkEnableOption "yabar";

      package = mkOption {
        type        = types.package;
        default     = pkgs.yabar;
        defaultText = "pkgs.yabar";
        example     = literalExample "pkgs.yabar-unstable";
        description = ''
          yabar package to use.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = null;
        example     = "${cfg.package}/share/yabar/examples/example.config";
        description = ''
          Path to the yabar configuration file.
          If null, $HOME/.config/yabar/yabar.conf will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.yabar = {
      description = "yabar service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = let
          arg = optionalString (!isNull cfg.configFile) " -c ${cfg.configFile}";
        in "${cfg.package}/bin/yabar${arg}";
        Restart = "always";
      };
    };
  };
}
