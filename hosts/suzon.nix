{ config, lib, pkgs, ... }:

{
  # MacBook Pro (Late 2016, 13-inch)
  networking.hostName = "suzon";

  imports = [
    ../darwin-common.nix
  ];

  nix = {
    buildCores = 4;
    maxJobs = 4;
  };
}
