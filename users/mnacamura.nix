{ config, lib, pkgs, ... }:

{
  users.users.mnacamura = {
    description = "Mitsuhiro Nakamura";

    uid = 1000;

    isNormalUser = true;

    createHome = true;

    extraGroups = [ "wheel" ]
    ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ];

    shell = "${pkgs.fish}/bin/fish";
  };
}
