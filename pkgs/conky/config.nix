{ config, lib, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ../../data/config/conky/conky.conf;

  gap_x = toString (140 * scale);
})
