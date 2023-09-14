{ config, lib, pkgs, ... }:

{
  # MacBook Pro (Late 2016, 13-inch)
  networking.hostName = "suzon";

  imports = [
    ../../common/darwin.nix
  ];

  nix = {
    buildCores = 4;
    settings.max-jobs = 4;
  };
}
