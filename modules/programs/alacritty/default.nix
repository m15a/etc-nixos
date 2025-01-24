{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.alacritty;

  inherit (pkgs.stdenv) hostPlatform;
  toml = pkgs.formats.toml { };

  configFile = toml.generate "alacritty.toml" cfg.config;

  wrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";
    paths = [ cfg.package ];
    pathsToLink = [
      "/share"
      "/nix-support"
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild =
      ''
        mkdir "$out/bin"
        makeWrapper "${cfg.package}/bin/alacritty" "$out/bin/alacritty" \
            --add-flags "--config-file '${configFile}'"
      ''
      + lib.optionalString hostPlatform.isDarwin ''
        app_contents="/Applications/Alacritty.app/Contents"
        mkdir -p "$out$app_contents"
        for name in Info.plist Resources; do
            ln -s "${cfg.package}$app_contents/$name" "$out$app_contents/$name"
        done
        mkdir "$out$app_contents/MacOS"
        ln -s "$out/bin/alacritty" "$out$app_contents/MacOS/"
      '';
  };
in

{
  options = {
    programs.alacritty = {
      enable = lib.mkEnableOption "Alacritty";
      package = lib.mkPackageOption pkgs "alacritty" { };
      config = lib.mkOption {
        inherit (toml) type;
        default = { };
        description = ''
          Alacritty configuration.
          If empty, configuration found in home directory will be used.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (if cfg.config == { } then cfg.package else wrapped)
    ];
  };
}
