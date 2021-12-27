{ config, lib, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
in

substituteAll {
  src = ./sxhkdrc;

  window_move_step = toString (10 * scale);
}
