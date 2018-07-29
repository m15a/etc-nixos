# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "louise";

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
    ];

  boot = {
    kernelParams = [
      # See https://gist.github.com/greigdp/bb70fbc331a0aaf447c2d38eacb85b8f#sleep-mode-power-usage
      "mem_sleep_default=deep"
      # DMAR: DRHD: handling fault status reg 2
      # See https://bbs.archlinux.org/viewtopic.php?id=230362
      "intel_iommu=off"
      # See https://wiki.archlinux.org/index.php/Power_management#Bus_power_management
      # "pcie_aspm=force"  # questionable if it is effective on Dell XPS 9370
    ];
    blacklistedKernelModules = [
      # See https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Remove_psmouse_errors_from_dmesg
      "psmouse"
    ];
    extraModprobeConfig = ''
      # See https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Module-based_Powersaving_Options
      options i915 modeset=1 enable_rc6=1 enable_guc_loading=1 enable_guc_submission=1 enable_psr=0
    '';
    kernel.sysctl."vm.swappiness" = 10;
    earlyVconsoleSetup = true;  # for HiDPI display
  };

  hardware = {
    # Enjoy Steam.
    pulseaudio.support32Bit = true;
    opengl.driSupport32Bit = true;
  };

  i18n.consoleFont = "latarcyrheb-sun32";  # for HiDPI display

  nix.buildCores = 8;

  environment = {
    systemPackages = with pkgs; [
      xorg.xbacklight
    ];
    variables = {
      # For HiDPI display
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = "2";
      GDK_DPI_SCALE = "0.5";
    };
  };

  services = {
    thermald.enable = true;
    tlp.enable = true;
    tlp.extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
    '';
    xserver.enable = true;
    compton.enable = true;
  };

  services.xserver = {
    # exportConfiguration = true;
    dpi = 192;  # for HiDPI (96dpi * 2)
    layout = "us";
    xkbOptions = "terminate:ctrl_alt_bksp,ctrl:swapcaps";
    # Enable touchpad support.
    libinput.enable = true;
    libinput.accelSpeed = "1";
    libinput.naturalScrolling = true;
    # Set the video card driver.
    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option "Backlight" "intel_backlight"
    '';
    # Extra devices.
    inputClassSections = [
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
    shadowOffsets = [(-24) (-30)];
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
      shadow-radius = 44;
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
