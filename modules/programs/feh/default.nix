{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.feh;

  wrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";
    paths = [ cfg.package.man ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mkdir "$out/bin"
      makeWrapper "${cfg.package.out}/bin/feh" "$out/bin/feh" \
          --add-flags "--image-bg '${cfg.config.imageBg}'"
    '';
  };
in

{
  options = {
    programs.feh = {
      enable = lib.mkEnableOption "feh";
      package = lib.mkPackageOption pkgs "feh" { };
      config = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = ''
          Feh configuration.
          If empty, configuration found in home directory will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (if cfg.config == { } then cfg.package else wrapped)
    ];
  };
}
