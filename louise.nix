{ config, pkgs, ... }:

{
  # Dell XPS 13 (9370)
  networking.hostName = "louise";

  imports = [
    ./hardware-configuration.nix
    ./common.nix
    ./private.nix
  ];

  boot = {
    kernelParams = [
      # https://gist.github.com/greigdp/bb70fbc331a0aaf447c2d38eacb85b8f#sleep-mode-power-usage
      "mem_sleep_default=deep"
      # DMAR: DRHD: handling fault status reg 2
      # https://bbs.archlinux.org/viewtopic.php?id=230362
      "intel_iommu=off"
    ];

    blacklistedKernelModules = [
      # https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Remove_psmouse_errors_from_dmesg
      "psmouse"
    ];

    extraModprobeConfig = ''
      # https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Module-based_Powersaving_Options
      options i915 modeset=1 enable_fbc=1 enable_guc=3 enable_psr=0
    '';

    kernel.sysctl."vm.swappiness" = 10;
  };

  hardware = {
    # cpu.intel.updateMicrocode = true;

    # bluetooth.powerOnBoot = false;

    # Enjoy Steam.
    steam-hardware.enable = true;  # Steam Controller
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
    thermald.enable = true;

    tlp.enable = true;
    tlp.extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
    '';
  };

  services.xserver = {
    videoDrivers = [ "intel" ];

    deviceSection = ''
      Option "Backlight" "intel_backlight"
    '';

    inputClassSections = [
      ''
        Identifier          "Disable touchscreen"
        MatchIsTouchscreen  "on"

        Option "Ignore"  "on"
      ''
      ''
        Identifier       "Built-in keyboard"
        MatchIsKeyboard  "on"
        MatchProduct     "AT Translated Set 2 keyboard"

        Option "XkbModel"    "pc104"
        Option "XkbLayout"   "us"
        Option "XkbVariant"  ""
        Option "XkbOptions"  "terminate:ctrl_alt_bksp,ctrl:swapcaps,altwin:swap_alt_win,ctrl:rctrl_ralt"
      ''
    ];
  };

  services.xserver.displayManager.setupCommands = let
    xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  in ''
    connected_monitors() {
      ${xrandr} -q | grep -w connected
    }

    other_than() {
      grep -v "^$1\>"
    }

    LID_is_open() {
      grep open /proc/acpi/button/lid/LID0/state 2>&1 >/dev/null
    }

    size_of() {
      ${xrandr} -q | grep "^$1\>" | grep -o '[[:digit:]]\+x[[:digit:]]\+'
    }

    LID=eDP1
    EXTS=$(connected_monitors | other_than "$LID" | cut -d' ' -f1)

    if [ -z "$EXTS" ] || LID_is_open; then
      MAIN="$LID"
    else
      MAIN=$(echo "$EXTS" | cut -d' ' -f1)
    fi
    SUBS=$(connected_monitors | other_than "$MAIN" | cut -d' ' -f1)

    CMD="${xrandr} --output $MAIN --primary --auto"

    SIZE=$(size_of "$MAIN")
    if [ -n "$SIZE" ]; then
      WIDTH=$(echo "$SIZE" | cut -d'x' -f1)
      HEIGHT=$(echo "$SIZE" | cut -d'x' -f2)
      if [ $WIDTH -lt 3840 ] || [ $HEIGHT -lt 2160 ]; then
        CMD="$CMD --scale 2x2"
      fi
    fi

    for SUB in $SUBS; do
      CMD="$CMD --output $SUB --off"
    done

    $CMD
  '';
}
