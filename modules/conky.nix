{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.conky;

  wrapped = if isNull cfg.configFile then cfg.package else
  pkgs.runCommand "conky-wrapped"
  { nativeBuildInputs = [ pkgs.makeWrapper ]; }
  ''
    makeWrapper ${cfg.package}/bin/conky $out/bin/conky \
        --add-flags "-c ${cfg.configFile}"
  '';
in

{
  options = {
    services.conky = {
      enable = mkEnableOption "conky";

      package = mkOption {
        type        = types.package;
        default     = pkgs.conky;
        defaultText = "pkgs.conky";
        example     = literalExample "pkgs.conky";
        description = ''
          conky package to use.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = null;
        example     = "${cfg.package.src}/data/conky.conf";
        description = ''
          Path to conky configuration file.
          If null, <code>$HOME/.config/conky/conky.conf</code> will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ wrapped ];

    services.xserver.displayManager.sessionCommands = ''
      ${wrapped}/bin/conky
    '';
  };
}
