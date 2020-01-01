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
      # http://tsueyasu.blogspot.jp/2012/03/amdwatchdog.html
      "sp5100_tco"
    ];

    extraModprobeConfig = ''
      options snd_hda_intel model=generic
    '';
  };

  hardware = {
    # cpu.amd.updateMicrocode = true;
  };

  nix.buildCores = 8;

  services = {
    # TODO: Fix it to run correctly.
    # thermald.enable = true;

    openssh.enable = true;
  };

  services.xserver = {
    videoDrivers = [ "amdgpu" ];

    xrandrHeads = [
      { output = "DisplayPort-1"; primary = true; }
    ];
  };
}
