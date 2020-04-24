{ config, lib, substituteAll, paper-icon-theme, papirus-icon-theme, xdg_utils }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colortheme;
in

substituteAll (colortheme // {
  src = ../../data/config/dunstrc;

  geometry = let
    width = toString (450 * scale);
    height = toString 5;
    d = x:
    "${if x >= 0 then "+" else ""}${toString (x * scale)}";
    # 23 is derived from [bspwm window gap: 60] / (1 + [phi: 1.618])
  in "${width}x${height}${d (1920 - 450 - 23)}${d (23 + 23)}";

  padding = toString (3 * scale);

  horizontal_padding = toString (5 * scale);

  max_icon_size = toString (24 * scale);

  icon_path = let
    s = toString (24 * scale);
    paper_paths = lib.concatStringsSep ":"
    (map (c: "${paper-icon-theme}/share/icons/Paper/${s}x${s}/${c}")
    [ "status" "devices" "apps" ]);
    # Fallback for e.g. dropbox, which is missing in Paper 24x24 and 48x48
    papirus_paths = lib.concatStringsSep ":"
    (map (c: "${papirus-icon-theme}/share/icons/Papirus/${s}x${s}/${c}")
    [ "status" "devices" "apps" ]);
  in "${paper_paths}:${papirus_paths}";

  browser = "${xdg_utils}/bin/xdg-open";
})
