{ config, lib, pkgs, ... }:

{
  # MacBook Pro (Late 2016, 13-inch)
  networking.hostName = "suzon";

  imports = [
    ../../common/darwin.nix
  ];

  nix = {
    settings.cores = 4;
    settings.max-jobs = 4;
  };
}
