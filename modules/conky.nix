{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.conky;

  wrapped = pkgs.runCommand "conky-wrapped"
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

      wrappedPackage = mkOption {
        type        = types.package;
        default     = wrapped;
        description = ''
          conky package wrapped with <code>config.services.conky.configFile</code>.
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
    environment.systemPackages = [
      (if isNull cfg.configFile
      then cfg.package
      else cfg.wrappedPackage)
    ];

    services.xserver.displayManager.sessionCommands = ''
      ${if isNull cfg.configFile then cfg.package else cfg.wrappedPackage}/bin/conky
    '';
  };
}
