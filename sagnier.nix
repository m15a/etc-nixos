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

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    btops
    dunst
    feh
    scrot
    lightlocker
    rofi
    termite
    yabar-unstable
    pavucontrol
  ] ++ [
    gtk3  # Required to use Emacs key bindings in GTK apps
    arc-theme
    papirus-icon-theme
    numix-cursor-theme
  ];
  programs.fish = {
    enable = true;
    shellInit = ''
      umask 077
    '';
    # Don't override aliases after loading snippets in ~/.config/fish.
    shellAliases = {};
  };
  programs.vim.defaultEditor = true;

  environment.variables = {
    # Apps launched in ~/.xprofile need it if they use SVG icons.
    GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Services for hardware optimizations.
  services.fstrim.enable = true;
  # services.thermald.enable = true;  # It does not work correctly.

  # Enable the chrony deamon.
  services.chrony.enable = true;

  # Enable the autofs daemon.
  services.autofs = {
    enable = true;
    autoMaster = let
      mapConf = pkgs.writeText "auto" ''
        usbdisk  -fstype=noauto,async,group,gid=100,fmask=117,dmask=007  :/dev/sdb1
      '';
    in ''
      /media  file:${mapConf}  --timeout=10
    '';
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.exportConfiguration = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp";

  # Set the video card driver.
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Extra monitor settings.
  services.xserver.xrandrHeads = [
    { output = "DisplayPort-1"; primary = true; }
  ];

  # Enable LightDM.
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = "/var/pixmaps/default.jpg";
  };
  services.xserver.displayManager.lightdm.greeters.mini = {
    enable = true;
    user = "mnacamura";
    extraConfig = ''
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

  # Enable bspwm.
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.desktopManager.default = "none";
  services.xserver.windowManager.default = "bspwm";

  # Enable compton.
  services.compton = {
    enable = true;

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
}
