{ config, lib, pkgs, ... }:

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
      for path in "${cfg.package}/bin/"*; do
          name="$(basename "$path")"
          if [ "$name" != rofi ]; then
              ln -s "$path" "$out/bin/$name"
          fi
      done
    '';
  };
in

{
  options = {
    programs.rofi = {
      enable = mkEnableOption "rofi";

      package = mkOption {
        type        = types.package;
        default     = pkgs.rofi;
        defaultText = "pkgs.rofi";
        example     = literalExample "pkgs.rofi";
        description = ''
          rofi package to use.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = null;
        description = ''
          Path to rofi configuration file.
          If null, $HOME/.config/rofi/config.rasi will be used.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (if isNull cfg.configFile
      then cfg.package
      else wrapped)
    ];
  };
}
