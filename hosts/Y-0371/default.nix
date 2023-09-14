{ config, lib, pkgs, ... }:

{
  # MacBook Pro (2020, 13-inch)
  networking.hostName = "Y-0371";

  imports = [
    ../../common/darwin.nix
  ];

  nix = {
    settings.cores = 4;
    settings.max-jobs = 4;
  };

  homebrew = {
    enable = true;
    brews = [
      "python3"
      "poetry"
    ];
  };

  environment = {
    systemPackages = [
      # pkgs.python3
    ];
  };
}
