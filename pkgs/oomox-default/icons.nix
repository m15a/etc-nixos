{ config, lib, themixPlugins, substituteAll }:

let
  colors = lib.mapAttrs (_: c: lib.substring 1 6 c) config.environment.colors.hex;
in

themixPlugins.icons-papirus.generate {
  preset = substituteAll (colors // { src = ./template; });
  name = "oomox-default";
} 
