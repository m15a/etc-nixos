# Load libinput module with my own config (esp. inputClassSections).
# See https://github.com/NixOS/nixpkgs/issues/75007.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.myLibinput;
in

{
  options = {
    services.xserver.myLibinput = {
      enable = mkEnableOption "my libinput options";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.modules = [ pkgs.xorg.xf86inputlibinput ];

    environment.systemPackages = [ pkgs.xorg.xf86inputlibinput ];

    environment.etc = let
      cfgPath = "X11/xorg.conf.d/40-libinput.conf";
    in {
      ${cfgPath} = {
        source = "${pkgs.xorg.xf86inputlibinput.out}/share/${cfgPath}";
      };
    };

    services.udev.packages = [ pkgs.libinput.out ];

    services.xserver.inputClassSections = [
      ''
        Identifier       "libinput touchpad"
        MatchDriver      "libinput"
        MatchIsTouchpad  "on"

        Option "AccelProfile"        "adaptive"
        Option "AccelSpeed"          "1"
        Option "DisableWhileTyping"  "on"
        Option "NaturalScrolling"    "on"
        Option "ScrollMethod"        "twofinger"
        Option "SendEventsMode"      "disabled-on-external-mouse"
        Option "Tapping"             "on"
        Option "TappingDragLock"     "on"
      ''
      ''
        Identifier      "libinput mouse"
        MatchDriver     "libinput"
        MatchIsPointer  "on"

        Option "AccelProfile"    "flat"
        Option "AccelSpeed"      "1"
        Option "SendEventsMode"  "enabled"
      ''
    ];
  };
}
