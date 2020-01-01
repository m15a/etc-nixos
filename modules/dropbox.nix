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
        Whether to enable Dropbox.
      '';
    };

    services.dropbox.users = mkOption {
      type = types.attrs;
      default = [];
      description = ''
        Dropbox users.
      '';
    };
  };

  config = mkIf cfg.enable {
    fileSystems = (flip mapAttrs') cfg.users (name: attrs:
    let
      path = if config.users.${name}.createHome
      then "${config.users.${name}.home}/Dropbox"
      else abort "dropbox: home directory does not exist for user '${name}'";
    in
    nameValuePair path {
      device = "/var/dropbox/${name}.img";
      fsType = "ext4";
      options = [ "loop" "defaults" "noatime" ];
    });
  };
}
