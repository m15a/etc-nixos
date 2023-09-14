{ config, lib, substituteAll, xdg_utils }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ./dunstrc;

  # TODO: Fix it to treat negative x correctly
  geometry = let
    width = toString (450 * hidpi.scale);
    height = toString 5;
    d = x:
    "${if x >= 0 then "+" else ""}${toString (x * hidpi.scale)}";
    # 23 is derived from [bspwm window gap: 60] / (1 + [phi: 1.618])
  in "${width}x${height}${d (- 23)}${d (46 - 4)}";

  padding = toString (3 * hidpi.scale);

  horizontal_padding = toString (5 * hidpi.scale);

  frame_width = toString (3 * hidpi.scale);

  min_icon_size = toString (36 * hidpi.scale);

  icon_path = let
    s = toString (24 * hidpi.scale);
    path = "/run/current-system/sw/share/icons/oomox-default";
  in lib.concatStringsSep ":"
  (map (c: "${path}/${s}x${s}/${c}") [ "status" "devices" "apps" ]);

  browser = "${xdg_utils}/bin/xdg-open";
})
