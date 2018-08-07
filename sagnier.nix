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
    windowManager.bspwm.configFile = pkgs.substituteAll {
      src = ./data/config/bspwmrc;
      postInstall = "chmod +x $out";
      window_gap = "60";
    };
  };

  services.compton = {
    shadowOffsets = [(-12) (-15)];
    # glx with amdgpu does not work for now
    # https://github.com/chjj/compton/issues/477
    # backend = "glx";
    # vSync = "opengl-swc";
    extraOptions = ''
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      paint-on-overlay = true;
      use-ewmh-active-win = true;
      sw-opti = true;
      unredir-if-possible = true;
      detect-transient = true;
      detect-client-leader = true;
      blur-kern = "3x3gaussian";
      glx-no-stencil = true;
      glx-copy-from-front = false;
      glx-use-copysubbuffermesa = true;
      glx-no-rebind-pixmap = true;
      glx-swap-method = "buffer-age";
      shadow-radius = 22;
      shadow-ignore-shaped = false;
      no-dnd-shadow = true;
      no-dock-shadow = true;
      clear-shadow = true;
    '';
  };
}
