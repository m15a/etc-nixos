# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
    xserver.enable = true;
    compton.enable = true;
  };

  services.xserver = {
    # exportConfiguration = true;
    layout = "us";
    xkbOptions = "terminate:ctrl_alt_bksp";
    # Set the video card driver.
    videoDrivers = [ "amdgpu" ];
    # Extra monitor settings.
    xrandrHeads = [
      { output = "DisplayPort-1"; primary = true; }
    ];
    # Enable LightDM and bspwm environment.
    displayManager.lightdm.enable = true;
    windowManager.bspwm.enable = true;
    desktopManager.default = "none";
    windowManager.default = "bspwm";
  };

  services.compton = {
    fade = true;
    fadeDelta = 5;
    fadeSteps = [ "0.03" "0.03" ];
    shadow = true;
    shadowOpacity = "0.46";
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

  services.xserver.displayManager.lightdm = {
    background = "/var/pixmaps/default.jpg";
    greeters.mini.enable = true;
    greeters.mini.user = "mnacamura";
    greeters.mini.extraConfig = ''
      [greeter-theme]
      font = Source Code Pro Medium
      font-size = 13pt
      text-color = "#fce8c3"
      error-color = "#f75341"
      window-color = "#d75f00"
      border-width = 0
      layout-space = 40
      password-color = "#fce8c3"
      password-background-color = "#1c1b19"
    '';
  };
}
