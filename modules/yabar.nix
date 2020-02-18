{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.yabar;

  yabarWrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";
    paths = [ cfg.package ];
    buildInputs = [ pkgs.makeWrapper ];
    pathsToLink = [ "/share" ];
    postBuild = ''
      mkdir $out/bin
      makeWrapper ${cfg.package}/bin/yabar $out/bin/yabar \
      --add-flags "-c ${cfg.configFile}"
    '';
  };
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
    environment.systemPackages = [ yabarWrapped ];
    services.xserver.displayManager.sessionCommands = ''
      ${yabarWrapped}/bin/yabar &
    '';
  };
}
