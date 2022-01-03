{ config, lib, writeText, substituteAll, runCommand }:

let
  inherit (config.environment) colors;
  inherit (config.hardware.video) hidpi;

  configFile = substituteAll (colors.hex // {
    src = ./alacritty.yml;

    winit_x11_scale_factor = toString hidpi.scale;
  });
in

configFile
