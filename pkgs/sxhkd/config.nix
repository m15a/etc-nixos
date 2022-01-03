{ config, lib, substituteAll }:

let
  inherit (config.hardware.video) hidpi;
in

substituteAll {
  src = ./sxhkdrc;

  window_move_step = toString (10 * hidpi.scale);
}
