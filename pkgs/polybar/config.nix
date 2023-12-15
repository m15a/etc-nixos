{ config, lib, writeShellScript, substituteAll, dropbox-cli, networkmanager
, bluez, libnotify, xdg_utils, terminal, pavucontrol, systemd
}:

let
  inherit (config.hardware.video.legacy) hidpi;
  colors = config.environment.colors.hex;

  # TODO: Generalize it
  isLaptop = lib.elem config.networking.hostName [ "louise" ];

  openURL = url:
  writeShellScript "open-url" ''
    export PATH=$PATH''${PATH:+:}/run/current-system/sw/bin
    ${xdg_utils}/bin/xdg-open "${url}"
  '';

  dropbox_status_icon = with colors;
  let
    cmd = "${dropbox-cli}/bin/dropbox";
    fg = brblack;
  in
  writeShellScript "dropbox-status-icon" ''
    dropbox_is_running() {
        # If $? = 0, confusingly, dropbox is not running!
        ${cmd} running 2>&1 >/dev/null
        test $? -ne 0
    }
    dropbox_is_synched() {
        case "$(${cmd} status 2>/dev/null)" in
            'Up to date' | '最新の状態')
            true;;
            *)
            false;;
        esac
    }
    if ! dropbox_is_running; then
        echo '%{F${fg}}󰇣%{F-}'
    elif dropbox_is_synched; then
        echo '󰇣'
    else
        echo '󰓦'
    fi
  '';

  notify_dropbox_status = writeShellScript "notify-dropbox-status" ''
    ${libnotify}/bin/notify-send -i dropbox Dropbox "$(${dropbox-cli}/bin/dropbox status)"
  '';

  bluetooth_status_icon = with colors;
  let
    cmd = "${bluez}/bin/bluetoothctl";
    fg = brblack;
  in writeShellScript "bluetooth-status-icon" ''
    bluetooth_is_powered() {
        test "$(${cmd} show 2>/dev/null | grep Powered: | cut -d' ' -f2)" = yes
    }
    connected_devices() {
        ${cmd} devices Connected 2>/dev/null | cut -d' ' -f3
    }
    show_device_icon() {
        if echo "$1" | grep -iq mouse; then
            echo -n '󰍽'
        elif echo "$1" | grep -iq hhkb; then
            echo -n '󰌌'
        elif echo "$1" | grep -iq controller; then
            echo -n '󰖺'
        else
            echo -n "$1"
        fi
    }
    if ! bluetooth_is_powered; then
        echo '%{F${fg}}󰂲%{F-}'
    else
        echo -n '󰂯 '
        for device in $(connected_devices); do
            show_device_icon "$device"
        done
    fi
  '';
  bluetooth_switch = let
    cmd = "${bluez}/bin/bluetoothctl";
  in writeShellScript "bluetooth-switch" ''
    bluetooth_is_powered() {
        test "$(${cmd} show 2>/dev/null | grep Powered: | cut -d' ' -f2)" = yes
    }
    if bluetooth_is_powered; then
        ${cmd} power off
    else
        ${cmd} power on
    fi
  '';
in

substituteAll (colors // {
  src = ./config;

  modules_left = lib.concatStringsSep " " [
    "date"
    "bspwm"
  ];
  modules_center = lib.concatStringsSep " " [
    "xwindow"
  ];
  modules_right = [
    "dropbox"
    "wifi"
    "bluetooth"
    "pulseaudio"
  ] ++ lib.optionals isLaptop [
    "battery"
  ];

  height = toString (22 * hidpi.scale);
  offset_y = toString (4 * hidpi.scale);
  inherit terminal;

  fonts = lib.concatStringsSep "\n"
  (lib.mapAttrsToList (i: s: "font-${i} = ${s}") {
    "0" = "mononoki Nerd Font:size=${toString (13 * hidpi.scale)}";
    "1" = "Rounded Mgen+ 1m:size=${toString (13 * hidpi.scale)}";
  });

  open_calendar = openURL "https://calendar.google.com/";
  inherit dropbox_status_icon notify_dropbox_status;
  open_dropbox = openURL "https://dropbox.com/";
  nmcli = "${networkmanager}/bin/nmcli";
  nmtui = "${networkmanager}/bin/nmtui";
  bluetoothctl = "${bluez}/bin/bluetoothctl";
  inherit bluetooth_status_icon bluetooth_switch;
  pavucontrol = "${pavucontrol}/bin/pavucontrol";
})
