{ config, lib, substituteAll }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ./bspwmrc;

  postInstall = "chmod +x $out";

  # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
  monocle_padding = toString (37 * hidpi.scale);
  window_gap = toString (60 * hidpi.scale);
  border_width = toString (2 * hidpi.scale);
})
