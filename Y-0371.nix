{ config, lib, pkgs, ... }:

{
  # MacBook Pro (2020, 13-inch)
  networking.hostName = "Y-0371";

  imports = [
    ./darwin-common.nix
  ];

  nix = {
    buildCores = 4;
    maxJobs = 4;
  };
}
