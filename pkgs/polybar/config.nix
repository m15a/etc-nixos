{ config, lib, writeShellScript, substituteAll, dropbox-cli, networkmanager
, bluez, libnotify, xdg_utils, termite, pavucontrol, systemd
}:

let
  inherit (config.environment.hidpi) scale;

  colors = config.environment.colors.hex;

  # TODO: Generalize it
  isLaptop = lib.elem config.networking.hostName [ "louise" ];

  openURL = url:
  writeShellScript "open-url" ''
    export PATH=$PATH''${PATH:+:}/run/current-system/sw/bin
    ${xdg_utils}/bin/xdg-open "${url}"
  '';

  dropbox_status_icon = with colors;
  let fg = brblack; in
  writeShellScript "dropbox-status-icon" ''
    dropbox="${dropbox-cli}/bin/dropbox"
    # If status = 0, confusingly, dropbox is not running!
    "$dropbox" running
    if [ $? -ne 0 ]; then
        status="$("$dropbox" status 2>/dev/null)"
        case "$status" in
            'Up to date'|'最新の状態')
                echo '󰇣'
                ;;
            *)
                echo '󰓦'
                ;;
        esac
    else
        echo '%{F${fg}}󰇣%{F-}'
    fi
  '';

  notify_dropbox_status = writeShellScript "notify-dropbox-status" ''
    ${libnotify}/bin/notify-send -i dropbox Dropbox "$(${dropbox-cli}/bin/dropbox status)"
  '';

  bluetoothStatusIcon = with colors;
  let fg = brblack; in
  writeShellScript "bluetooth-status-icon" ''
    btctl=${bluez}/bin/bluetoothctl
    if [ "$(${systemd}/bin/systemctl is-active bluetooth)" = active ] && \
       [ "$($btctl show | grep Powered | cut -d' ' -f2)" = yes ]; then
        echo -n '󰂯'
        for d in $($btctl paired-devices | cut -d' ' -f2); do
            if $btctl info "$d" | grep -q 'Connected: yes'; then
                alias="$($btctl info "$d" | grep 'Alias:' | cut -d' ' -f2)"
                if echo "$alias" | grep -iq mouse; then
                    echo -n '󰍽'
                elif echo "$alias" | grep -iq hhkb; then
                    echo -n '󰌌'
                elif echo "$alias" | grep -iq controller; then
                    echo -n '󰊴'
                else
                    echo -n "$alias "
                fi
            fi
        done
    else
        echo '%{F${fg}}󰂲%{F-}'
    fi
  '';
  bluetoothSwitch = writeShellScript "bluetooth-switch" ''
    btctl="${bluez}/bin/bluetoothctl"
    if [ "$($btctl show | grep Powered | cut -d' ' -f2)" = yes ]; then
        "$btctl" power off
    else
        "$btctl" power on
    fi
  '';
in

substituteAll (colors // {
  src = ../../data/config/polybar/config;

  height = toString (22 * scale);

  offset_y = toString (4 * scale);

  fonts = lib.concatStringsSep "\n" (lib.mapAttrsToList (i: s: "font-${i} = ${s}") {
    "0" = "mononoki:size=${toString (12 * scale)}";
    "1" = "Rounded Mgen+ 1m:size=${toString (12 * scale)}";
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
    "dropbox"
    "wifi"
    "bluetooth"
    "pulseaudio"
  ] ++ lib.optionals isLaptop [
    "battery"
  ];

  open_calendar = openURL "https://calendar.google.com/";

  termite = "${termite}/bin/termite";

  nmcli = "${networkmanager}/bin/nmcli";
  nmtui = "${networkmanager}/bin/nmtui";

  inherit dropbox_status_icon notify_dropbox_status;
  open_dropbox = openURL "https://dropbox.com/";


  bluetoothctl = "${bluez}/bin/bluetoothctl";
  bluetooth_status_icon = "${bluetoothStatusIcon}";
  bluetooth_switch = "${bluetoothSwitch}";

  pavucontrol = "${pavucontrol}/bin/pavucontrol";
})
