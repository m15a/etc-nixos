{ config, lib, writeShellScript, substituteAll, dropbox-cli, networkmanager
, bluez, libnotify, xdg_utils, terminal, pavucontrol, systemd
}:

let
  inherit (config.hardware.video.legacy) hidpi;
  colors = config.environment.colors.hex;
  dpi = toString (96 * hidpi.scale);

  # TODO: Generalize it
  isLaptop = lib.elem config.networking.hostName [ "louise" ];

  openURL = url:
  writeShellScript "open-url" ''
    export PATH=$PATH''${PATH:+:}/run/current-system/sw/bin
    ${xdg_utils}/bin/xdg-open "${url}"
  '';

  dropbox_status = with colors;
  let cmd = "${dropbox-cli}/bin/dropbox"; in
  writeShellScript "dropbox-status" ''
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
        echo '%{F${brblack}}󰇣%{F-}'
    elif dropbox_is_synched; then
        echo '󰇣'
    else
        echo '󰓦'
    fi
  '';
  dropbox_notify_status = writeShellScript "dropbox-notify-status" ''
    ${libnotify}/bin/notify-send -i dropbox Dropbox "$(${dropbox-cli}/bin/dropbox status)"
  '';

  wifi_settings = writeShellScript "wifi-settings" ''
    ${terminal} \
        -o window.dimensions.lines=30 \
        -o window.dimensions.columns=80 \
        --class nmtui \
        --title NetworkManager\ TUI \
        -e ${networkmanager}/bin/nmtui
  '';
  wifi_on = writeShellScript "wifi-on" ''
    ${networkmanager}/bin/nmcli radio wifi on
  '';
  wifi_off = writeShellScript "wifi-off" ''
    ${networkmanager}/bin/nmcli radio wifi off
  '';

  bluetooth_status = with colors;
  let cmd = "${bluez}/bin/bluetoothctl"; in
  writeShellScript "bluetooth-status" ''
    bluetooth_is_powered() {
        test "$(${cmd} show 2>/dev/null | grep Powered: | cut -d' ' -f2)" = yes
    }
    connected_devices() {
        ${cmd} devices Connected 2>/dev/null | cut -d' ' -f3
    }
    show_device_icon() {
        if echo "$1" | grep -iq mouse; then
            echo -n 󰍽
        elif echo "$1" | grep -iq hhkb; then
            echo -n 󰌌
        elif echo "$1" | grep -iq controller; then
            echo -n 󰖺
        else
            echo -n "$1"
        fi
    }
    if ! bluetooth_is_powered; then
        echo '%{F${brblack}}󰂲 %{F-}'
    else
        echo -n '󰂯 '
        devices=($(connected_devices))
        n=''${#devices[@]}
        for device in "''${devices[@]}"; do
            show_device_icon "$device"
            n=$((n - 1))
            [ $n > 0 ] && echo -n ' '
        done
    fi
  '';
  bluetooth_toggle = let cmd = "${bluez}/bin/bluetoothctl"; in
  writeShellScript "bluetooth-toggle" ''
    bluetooth_is_powered() {
        test "$(${cmd} show 2>/dev/null | grep Powered: | cut -d' ' -f2)" = yes
    }
    if bluetooth_is_powered; then
        ${cmd} power off
    else
        ${cmd} power on
    fi
  '';
  bluetooth_settings = writeShellScript "bluetooth-settings" ''
    ${terminal} \
        -o window.dimensions.lines=30 \
        -o window.dimensions.columns=80 \
        --class bluetoothctl \
        --title bluetoothctl \
        -e ${bluez}/bin/bluetoothctl
  '';

  pulseaudio_settings = writeShellScript "pulseaudio-settings" ''
    ${pavucontrol}/bin/pavucontrol
  '';
in

substituteAll (colors // {
  src = ./config;

  # [bar/top]
  dpi_x = dpi;
  dpi_y = dpi;
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

  # [module/date]
  open_calendar = openURL "https://calendar.google.com/";

  # [module/dropbox]
  inherit dropbox_status dropbox_notify_status;
  open_dropbox = openURL "https://dropbox.com/";

  # [module/wifi]
  inherit wifi_settings wifi_on wifi_off;

  # [module/bluetooth]
  inherit bluetooth_status bluetooth_toggle bluetooth_settings;

  # [module/pulseaudio]
  inherit pulseaudio_settings;
})
