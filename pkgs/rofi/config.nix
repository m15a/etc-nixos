{ config, lib, substituteAll, terminal }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ./config.rasi;

  dpi = toString (96 * hidpi.scale);

  font = "monospace 13";

  inherit terminal;
})
