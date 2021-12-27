{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.feh;

  inherit (config.environment) colors;

  wrapped = pkgs.buildEnv {
    name = "${cfg.package.name}-wrapped";

    paths = [ cfg.package.man ];

    buildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      mkdir "$out/bin"
      makeWrapper "${cfg.package.out}/bin/feh" "$out/bin/feh" \
          --add-flags "--image-bg '${cfg.imageBg}'"
    '';
  };
in

{
  options = {
    programs.feh = {
      enable = mkEnableOption "feh";

      package = mkOption {
        type        = types.package;
        default     = pkgs.feh;
        defaultText = "pkgs.feh";
        example     = literalExample "pkgs.feh";
        description = ''
          feh package to use.
        '';
      };

      wrappedPackage = mkOption {
        type        = types.package;
        default     = wrapped;
        description = ''
          feh package wrapped with --image-bg.
        '';
      };

      imageBg = mkOption {
        type        = with types; str;
        default     = colors.hex.black;
        description = ''
          Style as background for transparent image parts and the like.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.wrappedPackage ];
  };
}
