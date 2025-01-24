{
  config,
  lib,
  writeShellScript,
  substituteAll,
  networkmanager,
  bluez,
  libnotify,
  xdg_utils,
  terminal,
  pavucontrol,
  systemd,
}:

let
  inherit (config.hardware.video.legacy) hidpi;
  colors = config.environment.colors.hex;
  dpi = toString (96 * hidpi.scale);
  fcitx5 = config.i18n.inputMethod.package;

  # TODO: Generalize it
  isLaptop = lib.elem config.networking.hostName [ "louise" ];

  openURL =
    url:
    writeShellScript "open-url" ''
      export PATH=$PATH''${PATH:+:}/run/current-system/sw/bin
      ${xdg_utils}/bin/xdg-open "${url}"
    '';

  fcitx5_input_method =
    with colors;
    let
      cmd = "${fcitx5}/bin/fcitx5-remote";
    in
    writeShellScript "fcitx5-status" ''
      fcitx5_is_close() {
          test "$(${cmd} 2>/dev/null)" -eq 0
      }
      show_input_method() {
          local input_method
          input_method="$(${cmd} -n 2>/dev/null)"
          case "$input_method" in
              keyboard-*)
              echo -n "''${input_method^^}" | sed 's|KEYBOARD-||'
              ;;
              *)
              echo -n "''${input_method^}"
              ;;
          esac
      }
      if fcitx5_is_close; then
          echo '%{F${brblack}} %{F-}'
      else
          echo -n '󰌌 '
          show_input_method
      fi
    '';
  fcitx5_toggle = writeShellScript "fcitx5-toggle" ''
    ${fcitx5}/bin/fcitx5-remote -t
  '';
  fcitx5_settings = writeShellScript "fcitx5-settings" ''
    ${fcitx5}/bin/fcitx5-config-qt
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

  bluetooth_status =
    with colors;
    let
      cmd = "${bluez}/bin/bluetoothctl";
    in
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
              [ $n -gt 0 ] && echo -n ' '
          done
      fi
    '';
  bluetooth_toggle =
    let
      cmd = "${bluez}/bin/bluetoothctl";
    in
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

substituteAll (
  colors
  // {
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
    modules_right =
      [
        "fcitx5"
        "wifi"
        "bluetooth"
        "pulseaudio"
      ]
      ++ lib.optionals isLaptop [
        "battery"
      ];

    # [module/date]
    open_calendar = openURL "https://calendar.google.com/";

    # [module/fcitx]
    inherit fcitx5_input_method fcitx5_toggle fcitx5_settings;

    # [module/wifi]
    inherit wifi_settings wifi_on wifi_off;

    # [module/bluetooth]
    inherit bluetooth_status bluetooth_toggle bluetooth_settings;

    # [module/pulseaudio]
    inherit pulseaudio_settings;
  }
)
