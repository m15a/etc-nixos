{ config, lib, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
  colortheme = lib.mapAttrs (_: c: c.hex) config.environment.colortheme;

  makeRules = rules:
  lib.concatStringsSep "\n"
  (lib.mapAttrsToList (name: rule: "bspc rule --add ${name} ${rule}") rules);
in

substituteAll (colortheme // {
  src = ../../data/config/bspwm/bspwmrc;

  postInstall = "chmod +x $out";

  border_width = toString (1 * scale);

  window_gap = toString (60 * scale);

  # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
  monocle_padding = toString (37 * scale);

  rules = makeRules {
    Steam = "follow=no";
    Zathura = "state=tiled";
  };
})
