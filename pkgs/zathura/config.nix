{ config, lib, substituteAll }:

let
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ./zathurarc;
})
