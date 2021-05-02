{ config, lib, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colors;

  makeRules = rules:
  lib.concatStringsSep "\n"
  (lib.mapAttrsToList (name: rule: "bspc rule --add ${name} ${rule}") rules);
in

substituteAll (colors.hex // {
  src = ../../data/config/bspwm/bspwmrc;

  postInstall = "chmod +x $out";

  border_width = toString (3 * scale);

  window_gap = toString (60 * scale);

  # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
  monocle_padding = toString (37 * scale);

  rules = makeRules {
    Nightly = "state=tiled";
    Steam = "follow=no";
    Zathura = "state=tiled";
  };
})
