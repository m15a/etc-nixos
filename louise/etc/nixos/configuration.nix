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

  boot.kernelParams = [
    # See https://gist.github.com/greigdp/bb70fbc331a0aaf447c2d38eacb85b8f#sleep-mode-power-usage
    "mem_sleep_default=deep"

    # DMAR: DRHD: handling fault status reg 2
    # See https://bbs.archlinux.org/viewtopic.php?id=230362
    "intel_iommu=off"

    # See https://wiki.archlinux.org/index.php/Power_management#Bus_power_management
    # "pcie_aspm=force"  # questionable if it is effective on Dell XPS 9370
  ];

  boot.blacklistedKernelModules = [
    # See https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Remove_psmouse_errors_from_dmesg
    "psmouse"
  ];

  boot.extraModprobeConfig = ''
    # See https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Module-based_Powersaving_Options
    options i915 modeset=1 enable_rc6=1 enable_guc_loading=1 enable_guc_submission=1 enable_psr=0
  '';

  # For HiDPI display
  boot.earlyVconsoleSetup = true;

  # Various optimizations.
  boot.kernel.sysctl."vm.swappiness" = 10;

  networking.hostName = "louise"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "latarcyrheb-sun32";  # for HiDPI display
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
    xorg.xbacklight
    pavucontrol
  ] ++ [
    numix-cursor-theme
    # numix-icon-theme-circle
    adapta-gtk-theme
    adapta-backgrounds
  ];
  programs.fish.enable = true;
  programs.vim.defaultEditor = true;

  environment.variables = {
    # For HiDPI display
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Services for hardware optimizations.
  services.fstrim.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    CPU_SCALING_GOVERNOR_ON_AC=powersave
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
  '';

  # Enable the chrony deamon.
  # KDE runs nptdate at the start time so no need to do it.
  # services.chrony.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
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
  services.xserver.dpi = 192;  # for HiDPI (96dpi * 2)
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp,ctrl:swapcaps";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "1";
  services.xserver.libinput.naturalScrolling = true;

  # Set the video card driver.
  services.xserver.videoDrivers = [ "i915" ];

  # Extra devices.
  services.xserver.inputClassSections = [
    ''
      Identifier             "HHKB-BT"
      MatchIsKeyboard        "on"
      MatchDevicePath        "/dev/input/event*"
      MatchProduct           "HHKB-BT"
      Option "XkbModel"      "pc104"
      Option "XkbLayout"     "us"
      Option "XkbOptions"    "terminate:ctrl_alt_bksp"
      Option "XkbVariant"    ""
    ''
  ];

  # Enable LightDM and bspwm environment.
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = "${pkgs.adapta-backgrounds}/share/backgrounds/adapta/suna.jpg";
  };
  services.xserver.displayManager.lightdm.greeters.gtk = {
    indicators = [ "~clock" "~spacer" "~session" "~language" "~power" ];
    clock-format = "%m %e %a %H:%M";
    theme.name = "Adapta-Nokto";
    theme.package = pkgs.adapta-gtk-theme;
    # iconTheme.name = "Numix-Circle";
    # iconTheme.package = pkgs.numix-icon-theme-circle;
    extraConfig = ''
      xft-dpi=192
      font-name=Source Sans Pro 13
    '';
  };
  services.xserver.windowManager.bspwm.enable = true;
  services.compton = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeDelta = 3;
    shadow = true;
    shadowOpacity = "0.46";
    shadowOffsets = [(-7) (-7)];
    shadowExclude = [
      "name = 'yabar'"
    ];
    extraOptions = ''
      shadow-radius = 18;
    '';
  };
  # services.gnome3.gnome-keyring.enable = true;

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