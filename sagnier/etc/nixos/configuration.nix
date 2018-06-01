# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Mount options for Btrfs on SSD
  commonMountOptions = [ "defaults" "noatime" "compress=lzo" "commit=60" ];

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  fileSystems."/".options = commonMountOptions;
  fileSystems."/nix".options = commonMountOptions;
  fileSystems."/var".options = commonMountOptions;
  fileSystems."/home".options = commonMountOptions;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.blacklistedKernelModules = [
    # sp5100_tco: I/O address 0x0cd6 already in use
    # See http://tsueyasu.blogspot.jp/2012/03/amdwatchdog.html
    "sp5100_tco"
  ];

  boot.extraModprobeConfig = ''
    Set the sound card driver.
    options snd_hda_intel model=generic
  '';

  networking.hostName = "sagnier"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };
  };

  # Fonts
  fonts = {
    fonts = with pkgs; [
      source-serif-pro
      source-sans-pro
      source-code-pro
      source-han-serif-japanese
      source-han-sans-japanese
      noto-fonts-emoji
      font-awesome-ttf
      fira-code
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Source Serif Pro"
        "Source Han Serif JP"
      ];
      sansSerif = [
        "Source Sans Pro"
        "Source Han Sans JP"
      ];
      monospace = [
        "Source Code Pro"
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Nix options
  nix.trustedUsers = [ "@wheel" ];
  # nix.useSandbox = true;
  nix.buildCores = 8;
  nix.nixPath = [
    "nixpkgs=/var/repos/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # Nixpkgs options
  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    dunst
    feh
    scrot
    lightlocker
    rofi
    termite
    yabar-unstable
    pavucontrol
  ] ++ [
    gtk2 gtk3  # Required to use Emacs key bindings in GTK apps
    arc-theme
    papirus-icon-theme
    numix-cursor-theme
  ];
  programs.fish = {
    enable = true;
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 17886 ];  # for Jupyter
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];

  # Enable bluetooth.
  hardware.bluetooth.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enjoy Steam.
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.driSupport32Bit = true;

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
    # showPasswordLabel = false;
    theme = {
      font = "Source Code Pro Medium";
      fontSize = "13pt";
      textColor = "#fce8c3";
      errorColor = "#f75341";
      windowColor = "#d65d0e";
      passwordColor = "#fce8c3";
      passwordBackgroundColor = "#1c1b19";
      borderWidth = 0;
      layoutSpace = 20;
    };
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

    backend = "glx";
    vSync = "opengl-swc";
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mnacamura = {
    isNormalUser = true;
    uid = 1000;
    description = "Mitsuhiro Nakamura";
    extraGroups = [ "wheel" "networkmanager" ];
    createHome = true;
    shell = "/run/current-system/sw/bin/fish";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.nixos.stateVersion = "18.03"; # Did you read the comment?

}
