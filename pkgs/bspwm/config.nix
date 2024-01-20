{ config, lib, substituteAll }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // rec {
  src = ./bspwmrc;

  postInstall = "chmod +x $out";

  top_monocle_padding = toString (120 * hidpi.scale);
  bottom_monocle_padding = top_monocle_padding;
  left_monocle_padding = toString (360 * hidpi.scale);
  right_monocle_padding = left_monocle_padding;
  window_gap = toString (60 * hidpi.scale);
  border_width = toString (2 * hidpi.scale);
})
