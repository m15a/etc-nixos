{ config, pkgs, ... }:

{
  # Dell XPS 13 (9370)
  networking.hostName = "louise";

  imports = [
    ./hardware-configuration.nix
    ../../common/linux.nix
  ];

  boot = {
    kernelParams = [
      # Enter S3 deep sleep mode: https://wiki.archlinux.org/title/Dell_XPS_13_(9370)#Sleep
      "mem_sleep_default=deep"
      # DMAR: DRHD: handling fault status reg 2:
      # https://wiki.archlinux.org/title/Intel_graphics#No_sound_through_HDMI_on_a_Haswell_CPU
      "intel_iommu=on,igfx_off"
      # Framebuffer compression (FBC) can reduce power consumption while reducing memory bandwidth
      # needed for screen refreshes:
      # https://wiki.archlinux.org/title/intel_graphics#Framebuffer_compression_(enable_fbc)
      "i915.enable_fbc=1"
      # Panel Self Refresh (PSR), a power saving feature used by Intel iGPUs is known to cause
      # flickering in some instances:
      # https://wiki.archlinux.org/title/intel_graphics#Screen_flickering
      "i915.enable_psr=0"
      # Enable both GuC and HuC firmware loading (for processors before Gen 11)
      # https://wiki.archlinux.org/title/Intel_graphics#Enable_GuC_/
      "i915.enable_guc=2"
    ];

    blacklistedKernelModules = [
      # https://wiki.archlinux.org/index.php/Dell_XPS_13_(9360)#Remove_psmouse_errors_from_dmesg
      "psmouse"
    ];

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
    autorandr.enable = true;

    thermald.enable = true;

    throttled.enable = true;

    tlp.enable = true;
    tlp.settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };

    dropbox.enable = true;
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

    displayManager.setupCommands = let
      xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
      awk = "${pkgs.gawk}/bin/awk";
    in
    ''
      LID=eDP1
      EXTERNAL_MONITOR=DP1  # 4k display

      connected_monitors() {
          ${xrandr} -q | ${awk} -e '$2 == "connected" { print $1 }'
      }

      if connected_monitors | grep -qw "$EXTERNAL_MONITOR"; then
          ${xrandr} --output "$LID" --off --output "$EXTERNAL_MONITOR" --primary --auto --scale 1.5
      else
          ${xrandr} --output "$LID" --primary --auto --scale 1 --output "$EXTERNAL_MONITOR" --off
      fi
    '';
  };
}
