{ config, lib, substituteAll }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;

  makeRules = rules:
  lib.concatStringsSep "\n"
  (lib.mapAttrsToList (name: rule: "bspc rule --add ${name} ${rule}") rules);
in

substituteAll (colors.hex // {
  src = ./bspwmrc;

  postInstall = "chmod +x $out";

  border_width = toString (3 * hidpi.scale);

  window_gap = toString (60 * hidpi.scale);

  # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
  monocle_padding = toString (37 * hidpi.scale);

  rules = makeRules {
    firefox-nightly = "state=tiled";
    Steam = "follow=no";
    Zathura = "state=tiled";
    bluetoothctl = "state=floating";
    nmtui = "state=floating";
    Pavucontrol = "state=floating";
  };
})
