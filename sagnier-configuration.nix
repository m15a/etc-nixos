# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use Bluetooth.
  hardware.bluetooth.enable = true;

  # Use Pulseaudio.
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  boot.extraModprobeConfig = ''
    # Set the sound card driver.
    options snd_hda_intel model=generic
  '';

  boot.blacklistedKernelModules = [
    # sp5100_tco: I/O address 0x0cd6 already in use
    # See http://tsueyasu.blogspot.jp/2012/03/amdwatchdog.html
    "sp5100_tco"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
      cantarell-fonts
      fira-code
      noto-fonts-emoji
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
  nix.buildCores = 6;

  # Nixpkgs options
  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];
  programs.fish.enable = true;
  programs.vim.defaultEditor = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Services for optimizations.
  services.fstrim.enable = true;
  services.thermald.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 17886 ];  # for Jupyter
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;

  # Set the video card driver.
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Set the fallback keyboard.
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp";
 
  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

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
  system.stateVersion = "18.03"; # Did you read the comment?

}
