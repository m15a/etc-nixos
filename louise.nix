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

    bluetooth.powerOnBoot = false;

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
    xkbOptions = "terminate:ctrl_alt_bksp,ctrl:swapcaps";

    libinput.disableWhileTyping = true;

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
        Identifier       "HHKB-BT"
        MatchIsKeyboard  "on"
        MatchProduct     "HHKB-BT"

        Option "XkbModel"    "hhk"
        Option "XkbLayout"   "us"
        Option "XkbVariant"  ""
        Option "XkbOptions"  "terminate:ctrl_alt_bksp"
      ''
    ];
  };

  services.xserver.displayManager.setupCommands = let
    xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  in ''
    LID=eDP1
    EXTS=$(${xrandr} -q | grep '\<connected\>' | grep -v "^$LID\>" | cut -d' ' -f1)
    if [ -z "$EXTS" ]; then
        MAIN="$LID"
        if ${xrandr} -q | grep "^$MAIN\>" | grep "\<primary\>" 2>&1 >/dev/null; then
          MAIN_IS_PRIMARY=1
        fi
    else
      if grep open /proc/acpi/button/lid/LID0/state 2>&1 >/dev/null; then
        MAIN=$(${xrandr} -q | grep '\<connected primary\>' | cut -d' ' -f1)
        MAIN_IS_PRIMARY=1
      else
        MAIN=$(${xrandr} -q | grep '\<connected primary\>' | grep -v "^$LID\>" | cut -d' ' -f1)
        if [ -n "$MAIN" ]; then
          MAIN_IS_PRIMARY=1
        else
          MAIN=$(echo "$EXTS" | cut -d' ' -f1)
        fi
      fi
    fi
    SUBS=$(${xrandr} -q | grep '\<connected\>' | grep -v "^$MAIN\>" | cut -d' ' -f1)
    CMD="${xrandr} --output $MAIN --primary --auto"
    if [ -n "$MAIN_IS_PRIMARY" ]; then
      AREA=$(${xrandr} -q | grep "^$MAIN\>" | cut -d' ' -f4 | cut -d'+' -f1)
    else
      AREA=$(${xrandr} -q | grep "^$MAIN\>" | cut -d' ' -f3 | cut -d'+' -f1)
    fi
    WIDTH=$(echo "$AREA" | cut -d'x' -f1)
    HEIGHT=$(echo "$AREA" | cut -d'x' -f2)
    if [ $WIDTH -lt 3840 ] || [ $HEIGHT -lt 2160 ]; then
      CMD="$CMD --scale 2x2"
    fi
    for SUB in $SUBS; do
      CMD="$CMD --output $SUB --off"
    done
    $CMD
  '';
}
