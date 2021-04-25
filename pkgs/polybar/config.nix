{ config, lib, writeShellScript, substituteAll, dropbox-cli, networkmanager
, bluez, libnotify, xdg_utils, termite, pavucontrol
}:

let
  inherit (config.environment.hidpi) scale;

  colortheme = config.environment.colortheme.hex;

  # TODO: Generalize it
  isLaptop = lib.elem config.networking.hostName [ "louise" ];
in

substituteAll (colortheme // {
  src = ../../data/config/polybar/config;

  height = toString (22 * scale);

  offset_y = toString (4 * scale);

  fonts = lib.concatStringsSep "\n" (lib.mapAttrsToList (i: s: "font-${i} = ${s}") {
    "0" = "mononoki:size=${toString (12 * scale)}";
    "1" = "Source Code Pro:size=${toString (12 * scale)}";
    "2" = "Material Design Icons:size=${toString (12 * scale)}";
  });

  modules_left = lib.concatStringsSep " " [
    "date"
    "bspwm"
  ];
  modules_center = lib.concatStringsSep " " [
    "xwindow"
  ];
  modules_right = [
  ] ++ [
  ] ++ lib.optionals isLaptop [
    "wifi"
  ] ++ [
    "pulseaudio"
  ] ++ lib.optionals isLaptop [
    "battery"
  ];

  termite = "${termite}/bin/termite";

  nmcli = "${networkmanager}/bin/nmcli";
  nmtui = "${networkmanager}/bin/nmtui";

  pavucontrol = "${pavucontrol}/bin/pavucontrol";
})
