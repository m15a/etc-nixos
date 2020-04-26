{ config, ... }:

self: super:
{
  adapta-gtk-theme-colorpack = self.callPackage ./adapta-gtk-theme-colorpack {};

  adapta-gtk-theme-custom = with config.environment.colortheme;
  self.callPackage ./adapta-gtk-theme/custom.nix {
    selectionColor = brorange;
    accentColor = orange;
    suggestionColor = orange;
    destructionColor = red;
    enableParallel = true;
    enableTelegram = true;
  };

  configFiles = {
    gtk3 = self.callPackage ./gtk3/config.nix { inherit config; };

    dunst = self.callPackage ./dunst/config.nix { inherit config; };

    termite = self.callPackage ./termite/config.nix { inherit config; };

    yabar = with super;
    let
      inherit (config.environment.hidpi) scale;
      colortheme = lib.mapAttrs (_: c: "0x${lib.substring 1 7 c}")
      config.environment.colortheme;
      isLaptop = lib.elem config.networking.hostName [ "louise" ];
      dropboxStatusIcon = writeScript "dropbox-status-icon" ''
        #!${runtimeShell}
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
      wifiSwitch = writeScript "wifi-switch" ''
        #!${runtimeShell}
        nmcli="${networkmanager}/bin/nmcli"
        if [[ "$("$nmcli" radio wifi)" = enabled ]]; then
            "$nmcli" radio wifi off
        else
            "$nmcli" radio wifi on
        fi
      '';
      bluetoothStatusIcon = writeScript "bluetooth-status-icon" ''
        #!${runtimeShell}
        btctl="${bluez}/bin/bluetoothctl"
        if [[ "$("$btctl" show | grep Powered | cut -d' ' -f2)" = yes ]]; then
          echo ''
        else
          echo '!YFG0x44fce8c3Y!'
        fi
      '';
      bluetoothSwitch = writeScript "bluetooth-switch" ''
        #!${runtimeShell}
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
    in substituteAll (colortheme // {
      src = ../data/config/yabar.conf;
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
    });

    bspwm = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit (config.environment) colortheme;
    in
    substituteAll (colortheme // {
      src = ../data/config/bspwmrc;
      postInstall = "chmod +x $out";
      window_gap = toString (60 * scale);
        # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
        monocle_padding = toString (37 * scale);
    });

    sxhkd = let
      inherit (config.environment.hidpi) scale;
    in super.substituteAll {
      src = ../data/config/sxhkdrc;
      window_move_step = toString (10 * scale);
    };
  };

  wrapped = {
    feh = with super;
    let
      inherit (config.environment) colortheme;
    in
    buildEnv {
      name = "${feh.name}-wrapped";
      paths = [ feh.man ];
      buildInputs = [ makeWrapper ];
      postBuild = with colortheme; ''
        mkdir $out/bin
        makeWrapper ${feh.out}/bin/feh $out/bin/feh \
          --add-flags "--image-bg \"${black}\""
      '';
    };

    rofi = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit (config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ../data/config/rofi.conf;
        dpi = toString (96 * scale);
        font = "Source Code Pro Medium 13";
        terminal = "${termite}/bin/termite";
      });
    in
    buildEnv {
      name = "${rofi.name}-wrapped";
      paths = [ rofi ];
      pathsToLink = [ "/share" ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        mkdir $out/bin
        makeWrapper ${rofi}/bin/rofi $out/bin/rofi \
          --add-flags "-config ${configFile}"
        for path in ${rofi}/bin/*; do
          name="$(basename "$path")"
          [ "$name" != rofi ] && ln -s "$path" "$out/bin/$name"
        done
      '';
    };

    zathura = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit(config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ../data/config/zathurarc;
        font = "Source Code Pro 13";
        page_padding = toString scale;
      });
      configDir = runCommand "zathura-config-dir" {} ''
        install -D -m 444 "${configFile}" "$out/zathurarc"
      '';
    in
    buildEnv {
      name = "${zathura.name}-wrapped";
      paths = [ zathura ];
      pathsToLink = [ "/share" ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        mkdir $out/bin
        makeWrapper ${zathura}/bin/zathura $out/bin/zathura \
          --add-flags "--config-dir ${configDir}"
      '';
    };
  };
}
