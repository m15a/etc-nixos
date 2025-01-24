{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.zathura;
  configDir = pkgs.runCommand "zathura-config-dir" { } ''
    install -Dm444 "${cfg.configFile}" "$out/zathurarc"
  '';
  wrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";
    paths = [ cfg.package ];
    pathsToLink = [ "/share" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
        mkdir "$out/bin"
      makeWrapper "${zathura}/bin/zathura" "$out/bin/zathura" \
          --add-flags "--config-dir '${configDir}'"
    '';
  };
in

{
  options = {
    programs.zathura = {
      enable = mkEnableOption "zathura";
      package = lib.mkPackageOption pkgs "zathura" { };
      configFile = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Path to zathura configuration file.
          If null, $HOME/.config/zathura/config.rasi will be used.
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
