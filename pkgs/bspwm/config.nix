{ config, lib, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colortheme;
in

substituteAll (colortheme // {
  src = ../../data/config/bspwm/bspwmrc;

  postInstall = "chmod +x $out";

  border_width = toString (1 * scale);

  window_gap = toString (60 * scale);

  # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
  monocle_padding = toString (37 * scale);
})
