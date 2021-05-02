{ config, lib, substituteAll, termite }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ../../data/config/rofi/config.rasi;

  dpi = toString (96 * scale);

  font = "monospace 13";

  terminal = "${termite}/bin/termite";
})
