{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dropbox;
in

{
  options = {
    services.dropbox.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable Dropbox as a systemd user service.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.dropbox-cli ];

    networking.firewall = {
      allowedTCPPorts = [ 17500 ];
      allowedUDPPorts = [ 17500 ];
    };

    systemd.user.services.dropbox = {
      description = "Dropbox service";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        KillMode = "control-group";  # upstream recommends process
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };
    };
  };
}
