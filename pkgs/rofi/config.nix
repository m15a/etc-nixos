{ config, lib, substituteAll, termite }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colortheme;
in

substituteAll (colortheme.hex // {
  src = ../../data/config/rofi/config.rasi;

  dpi = toString (96 * scale);

  font = "monospace 11";

  terminal = "${termite}/bin/termite";
})
