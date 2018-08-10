{ config, pkgs, ... }:

{
  networking.hostName = "louise";

  imports = [
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
    ];

    blacklistedKernelModules = [
      # See https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Remove_psmouse_errors_from_dmesg
      "psmouse"
    ];

    extraModprobeConfig = ''
      # See https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Module-based_Powersaving_Options
      options i915 modeset=1 enable_fbc=1 enable_guc=3 enable_psr=0
    '';

    kernel.sysctl."vm.swappiness" = 10;
  };

  hardware = {
    # Enjoy Steam.
    pulseaudio.support32Bit = true;
    opengl.driSupport32Bit = true;
  };

  nix.buildCores = 8;

  environment = {
    hidpi.enable = true;

    systemPackages = with pkgs; [
      xorg.xbacklight
    ];
  };

  services = {
    chrony.servers = [
      # Add 'offline' as it is laptop
      "0.nixos.pool.ntp.org offline"
      "1.nixos.pool.ntp.org offline"
      "2.nixos.pool.ntp.org offline"
      "3.nixos.pool.ntp.org offline"
    ];

    thermald.enable = true;

    tlp.enable = true;
    tlp.extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
    '';
  };

  services.xserver = {
    xkbOptions = "terminate:ctrl_alt_bksp,ctrl:swapcaps";

    # Enable touchpad support.
    libinput.enable = true;
    libinput.accelSpeed = "1";
    libinput.naturalScrolling = true;

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
  };
}
