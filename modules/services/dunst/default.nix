{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dunst;
in

{
  options = {
    services.dunst = {
      enable = lib.mkEnableOption "dunst";
      package = lib.mkPackageOption pkgs "dunst" { };
      configFile = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        example = "${cfg.package}/share/dunst/dunstrc";
        description = ''
          Path to the dunst configuration file.
          If null, $HOME/.config/dunst/dunstrc will be used.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.user.services.dunst = {
      description = "dunst service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart =
          let
            arg = "-conf ${cfg.configFile}";
          in
          concatStringsSep " " (
            [
              "${cfg.package}/bin/dunst"
            ]
            ++ optional (cfg.configFile != null) arg
          );
        Restart = "always";
      };
    };
  };
}
