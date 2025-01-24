{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.mnacamura = {
    description = "NAKAMURA Mitsuhiro";
    uid = 1000;
    isNormalUser = true;
    createHome = true;
    extraGroups =
      [ "wheel" ]
      ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
      ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ];
    shell = "${pkgs.fish}/bin/fish";
  };
}
