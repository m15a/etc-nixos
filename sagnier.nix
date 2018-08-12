{ config, pkgs, ... }:

{
  # LEVEL-R0X3-R8X-XZL (BTO PC)
  networking.hostName = "sagnier";

  imports = [
    ./hardware-configuration.nix
    ./common.nix
    ./private.nix
  ];

  boot = {
    blacklistedKernelModules = [
      # sp5100_tco: I/O address 0x0cd6 already in use
      # See http://tsueyasu.blogspot.jp/2012/03/amdwatchdog.html
      "sp5100_tco"
    ];

    extraModprobeConfig = ''
      options snd_hda_intel model=generic
    '';
  };

  nix.buildCores = 8;

  services = {
    # TODO: fix it to run correctly.
    # thermald.enable = true;

    openssh.enable = true;
  };

  services.xserver = {
    xkbOptions = "terminate:ctrl_alt_bksp";

    videoDrivers = [ "amdgpu" ];

    xrandrHeads = [
      { output = "DisplayPort-1"; primary = true; }
    ];
  };
}
