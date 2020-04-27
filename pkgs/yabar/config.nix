{ config, lib, writeShellScript, substituteAll, dropbox-cli, networkmanager
, bluez, libnotify, xdg_utils, termite, pavucontrol
}:

let
  inherit (config.environment.hidpi) scale;

  colortheme = lib.mapAttrs (_: c: "0x${lib.substring 1 7 c}")
  config.environment.colortheme;

  # TODO: Generalize it
  isLaptop = lib.elem config.networking.hostName [ "louise" ];

  dropboxStatusIcon = writeShellScript "dropbox-status-icon" ''
    dropbox="${dropbox-cli}/bin/dropbox"
    # If status = 0, confusingly, dropbox is not running!
    "$dropbox" running
    if [[ $? -ne 0 ]]; then
      status="$("$dropbox" status 2>/dev/null)"
      if [[ "$status" = 'Up to date' || "$status" = '最新の状態' ]]; then
        echo ''
      else
        echo ''
      fi
    else
      echo '!YFG0x44fce8c3Y!'
    fi
  '';

  wifiSwitch = writeShellScript "wifi-switch" ''
    nmcli="${networkmanager}/bin/nmcli"
    if [[ "$("$nmcli" radio wifi)" = enabled ]]; then
        "$nmcli" radio wifi off
    else
        "$nmcli" radio wifi on
    fi
  '';

  bluetoothStatusIcon = writeShellScript "bluetooth-status-icon" ''
    btctl="${bluez}/bin/bluetoothctl"
    if [[ "$("$btctl" show | grep Powered | cut -d' ' -f2)" = yes ]]; then
      echo ''
    else
      echo '!YFG0x44fce8c3Y!'
    fi
  '';

  bluetoothSwitch = writeShellScript "bluetooth-switch" ''
    btctl="${bluez}/bin/bluetoothctl"
    if [[ "$($btctl show | grep Powered | cut -d' ' -f2)" = yes ]]; then
        "$btctl" power off
    else
        "$btctl" power on
    fi
  '';

  makeBlockList = blockNames:
  let
    contents = lib.concatStringsSep ", " (map (b: "\"${b}\"") blockNames);
  in
  "[ ${contents} ]";
in

substituteAll (colortheme // {
  src = ../../data/config/yabar/yabar.conf;

  height = toString (23 * scale);

  gap_horizontal = toString (5 * scale);

  slack_size = toString (5 * scale);

  font = "Source Sans Pro, FontAwesome ${toString (13 * scale)}";

  top_block_list = makeBlockList ([
    "date"
    "workspace"
    "title"
    "dropbox"
  ] ++ lib.optionals isLaptop [
    "wifi"
  ] ++ [
    "bluetooth"
    "volume"
  ] ++ lib.optionals isLaptop [
    "battery"
  ]);

  date_fixed_size = toString (125 * scale);

  workspace_fixed_size = toString (42 * scale);

  bspc = "${config.services.xserver.windowManager.bspwm.package}/bin/bspc";

  title_fixed_size = toString (1343 * scale);

  dropbox_fixed_size = toString (18 * scale);
  dropbox = "${dropbox-cli}/bin/dropbox";
  dropbox_status_icon = "${dropboxStatusIcon}";

  notify_send = "${libnotify}/bin/notify-send";

  browser = "${xdg_utils}/bin/xdg-open";

  wifi_fixed_size = toString (201 * scale);
  wifi_switch = "${wifiSwitch}";

  termite = "${termite}/bin/termite";

  nmtui = "${networkmanager}/bin/nmtui";

  bluetooth_fixed_size = toString (12 * scale);
  bluetoothctl = "${bluez}/bin/bluetoothctl";
  bluetooth_status_icon = "${bluetoothStatusIcon}";
  bluetooth_switch = "${bluetoothSwitch}";

  volume_fixed_size = toString (63 * scale);
  pactl = "${config.hardware.pulseaudio.package}/bin/pactl";
  pavucontrol = "${pavucontrol}/bin/pavucontrol";

  battery_fixed_size = toString (71 * scale);
})
