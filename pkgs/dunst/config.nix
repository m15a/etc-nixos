{ config, lib, substituteAll, xdg_utils }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ./dunstrc;

  browser = "${xdg_utils}/bin/xdg-open";
})
