{ config, lib, substituteAll, xdg_utils }:

let
  inherit (config.hardware.video.legacy) hidpi;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // rec {
  src = ./dunstrc;

  icon_theme = "oomox-default";
  icon_path = let
    s = toString (24 * hidpi.scale);
    path = "/run/current-system/sw/share/icons/${icon_theme}";
  in lib.concatStringsSep ":"
  (map (c: "${path}/${s}x${s}/${c}") [ "status" "devices" "apps" ]);

  browser = "${xdg_utils}/bin/xdg-open";
})
