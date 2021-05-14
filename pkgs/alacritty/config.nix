{ config, lib, writeText, substituteAll, runCommand }:

let
  inherit (config.environment) colors;

  configFile = substituteAll (colors.hex // {
    src = ../../data/config/alacritty/alacritty.yml;
  });
in

configFile
