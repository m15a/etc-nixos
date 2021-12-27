{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.alacritty;

  wrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";

    paths = [ cfg.package ];
    pathsToLink = [ "/share" "/nix-support" ];

    buildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      mkdir "$out/bin"
      makeWrapper "${cfg.package}/bin/alacritty" "$out/bin/alacritty" \
          --add-flags "--config-file '${cfg.configFile}'"
      for path in "${cfg.package}/bin/"*; do
          name="$(basename "$path")"
          if [ "$name" != alacritty ]; then
              ln -s "$path" "$out/bin/$name"
          fi
      done
    '';
  };
in

{
  options = {
    programs.alacritty = {
      enable = mkEnableOption "alacritty";

      package = mkOption {
        type        = types.package;
        default     = pkgs.alacritty;
        defaultText = "pkgs.alacritty";
        example     = literalExample "pkgs.alacritty";
        description = ''
          alacritty package to use.
        '';
      };

      wrappedPackage = mkOption {
        type        = types.package;
        default     = wrapped;
        description = ''
          alacritty package wrapped with <code>config.programs.alacritty.configFile</code>.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = null;
        description = ''
          Path to alacritty configuration file.
          If null, $HOME/.config/alacritty/alacritty.yml will be used.
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
  };
}
