{ config, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colortheme;
in

substituteAll (colortheme // {
  src = ../../data/config/zathura/zathurarc;

  font = "Source Code Pro 13";

  page_padding = toString scale;
})
