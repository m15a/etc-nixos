{ config, lib, writeText, substituteAll, runCommand }:

let
  inherit (config.environment) colors;
  inherit (config.hardware.video.legacy) hidpi;

  configFile = substituteAll (colors.hex // {
    src = ./alacritty.toml;

    winit_x11_scale_factor = toString hidpi.scale;
  });
in

configFile
