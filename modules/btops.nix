{ config, lib, pkgs, ... }:

with lib;

let
  bwmcfg = config.services.xserver.windowManager.bspwm;
  cfg = config.services.xserver.windowManager.bspwm.btops;

  defaultConfigFile = pkgs.writeText "btops-config.toml" ''
    watch-config = false
  '';

  configHome = pkgs.runCommand "btops-config-home" {} ''
    file="${cfg.configFile}"
    ext="''${file##*.}"
    install -D -m 444 "$file" "$out/btops/config.$ext"
  '';

  btopsWrapper = pkgs.runCommand "btops-wrappper"
  { nativeBuildInputs = [ pkgs.makeWrapper ]; }
  ''
    makeWrapper ${cfg.package}/bin/btops $out/bin/btops \
      --set XDG_CONFIG_HOME ${configHome}
  '';
in

{
  options = {
    services.xserver.windowManager.bspwm.btops = {
      enable = mkEnableOption "btops";

      package = mkOption {
        type        = types.package;
        default     = pkgs.btops;
        defaultText = "pkgs.btops";
        example     = "pkgs.btops";
        description = ''
          btops package to use.
        '';
      };

      configFile = mkOption {
        type        = with types; nullOr path;
        default     = "${defaultConfigFile}";
        example     = "${cfg.package.src}/examples/minmax.toml";
        description = ''
          Path to the btops configuration file.
          If null, $HOME/.config/btops/config.* will be used.
          Make sure that the file has an appropreate extension such as .toml,
          .yml, or .json (btops use Viper to load a configuration file).
        '';
      };
    };
  };

  config = mkIf (bwmcfg.enable && cfg.enable) {
    systemd.user.services.btops = {
      description = "btops service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      script = ''
          ${btopsWrapper}/bin/btops
      '';

      serviceConfig.Restart = "always";
    };
  };
}
