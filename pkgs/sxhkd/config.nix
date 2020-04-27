{ config, lib, substituteAll }:

let
  inherit (config.environment.hidpi) scale;
in

substituteAll {
  src = ../../data/config/sxhkd/sxhkdrc;

  window_move_step = toString (10 * scale);
}
