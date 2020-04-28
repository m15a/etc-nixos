{ config, substituteAll, termite }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colortheme;
in

substituteAll (colortheme // {
  src = ../../data/config/rofi/config.rasi;

  dpi = toString (96 * scale);

  font = "Source Code Pro Medium 13";

  terminal = "${termite}/bin/termite";
})
