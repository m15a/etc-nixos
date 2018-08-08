{ config, pkgs, ... }:

{
  networking.hostName = "sagnier";

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
    ];

  boot = {
    blacklistedKernelModules = [
      # sp5100_tco: I/O address 0x0cd6 already in use
      # See http://tsueyasu.blogspot.jp/2012/03/amdwatchdog.html
      "sp5100_tco"
    ];
    extraModprobeConfig = ''
      Set the sound card driver.
      options snd_hda_intel model=generic
    '';
  };

  nix.buildCores = 8;

  services = {
    # thermald.enable = true;  # It does not work correctly.
    openssh.enable = true;
  };

  services.xserver = {
    xkbOptions = "terminate:ctrl_alt_bksp";
    # Set the video card driver.
    videoDrivers = [ "amdgpu" ];
    # Extra monitor settings.
    xrandrHeads = [
      { output = "DisplayPort-1"; primary = true; }
    ];
  };
}
