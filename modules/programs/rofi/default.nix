{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.rofi;

  wrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";
    paths = [ cfg.package ];
    pathsToLink = [ "/share" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mkdir "$out/bin"
      makeWrapper "${cfg.package}/bin/rofi" "$out/bin/rofi" \
          --add-flags "-config '${cfg.configFile}'"
      ln -s "${cfg.package}/bin/rofi-sensible-terminal" "$out/bin/"
    '';
  };
in

{
  options = {
    programs.rofi = {
      enable = mkEnableOption "rofi";
      package = lib.mkPackageOption pkgs "rofi" { };
      configFile = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Path to rofi configuration file.
          If null, $HOME/.config/rofi/config.rasi will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (if (cfg.configFile == null) then cfg.package else wrapped)
    ];
  };
}
