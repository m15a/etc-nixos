{ config, lib, writeText, substituteAll, runCommand }:

let
  inherit (config.environment) colors;

  configFile = substituteAll (colors.hex // {
    src = ../../data/config/alacritty/alacritty.yml;

    winit_x11_scale_factor = toString config.environment.hidpi.scale;
  });
in

configFile
