{ config, ... }:

self: super:
{
  configFiles = {
    gtk3 = with super;
    let
      inherit (config.environment.hidpi) scale;
      gtkCss = writeText "gtk.css" ''
        VteTerminal, vte-terminal {
            padding-left: ${toString (2 * scale)}px;
        }
      '';
      settingsIni = writeText "settings.ini" ''
        [Settings]
        gtk-font-name = Source Han Sans JP 11
        gtk-theme-name = Arc
        gtk-icon-theme-name = Papirus
        gtk-key-theme-name = Emacs
      '';
    in runCommand "gtk-3.0" {} ''
        confd="$out/etc/xdg/gtk-3.0"
        install -D -m 444 "${gtkCss}" "$confd/gtk.css"
        install -D -m 444 "${settingsIni}" "$confd/settings.ini"
    '';

    dunst = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit (config.environment) colortheme;
    in
    substituteAll (colortheme // {
      src = ./data/config/dunstrc;
      geometry = let
        width = toString (450 * scale);
        height = toString 5;
        d = x:
        "${if x >= 0 then "+" else ""}${toString (x * scale)}";
        # 23 is derived from [bspwm window gap: 60] / (1 + [phi: 1.618])
      in "${width}x${height}${d (1920 - 450 - 23)}${d (23 + 23)}";
      font = "Source Sans Pro 13";
      max_icon_size = toString (24 * scale);
      icon_path = let
        s = toString (24 * scale);
        path = "${papirus-icon-theme}/share/icons/Papirus";
      in lib.concatStringsSep ":"
      (map (cat: "${path}/${s}x${s}/${cat}") [ "status" "devices" "apps" ]);
      browser = "${xdg_utils}/bin/xdg-open";
      padding = toString (3 * scale);
      horizontal_padding = toString (5 * scale);
    });

    yabar = with super;
    let
      inherit (config.environment.hidpi) scale;
      colortheme = lib.mapAttrs (_: c: "0x${lib.substring 1 7 c}")
      config.environment.colortheme;
      dropboxStatusIcon = writeScript "dropbox-status-icon" ''
        #!${runtimeShell}
        dropbox="${dropbox-cli}/bin/dropbox"
        # If status = 0, confusingly, dropbox is not running!
        "$dropbox" running
        if [[ $? -ne 0 ]]; then
          status=$("$dropbox" status 2>/dev/null)
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
        if [[ "$($nmcli radio wifi)" = enabled ]]; then
            "$nmcli" radio wifi off
        else
            "$nmcli" radio wifi on
        fi
      '';
      bluetoothStatusIcon = writeScript "bluetooth-status-icon" ''
        #!${runtimeShell}
        btctl="${bluez}/bin/bluetoothctl"
        if [[ "$($btctl show | grep Powered | cut -d' ' -f2)" = yes ]]; then
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
      src = ./data/config/yabar.conf;
      height = toString (23 * scale);
      gap_horizontal = toString (5 * scale);
      slack_size = toString (5 * scale);
      font = "Source Sans Pro, FontAwesome ${toString (13 * scale)}";
      top_block_list = makeBlockList ([ "workspace" "title" "dropbox" ]
        ++ ( if config.networking.hostName == "louise"  # TODO: Generalize it.
             then [ "wifi" "bluetooth" "volume" "battery" ]
             else [ "bluetooth" "volume" ]
           ) ++ [ "date" ]);
      workspace_fixed_size = toString (42 * scale);
      bspc = "${config.services.xserver.windowManager.bspwm.package}/bin/bspc";
      title_fixed_size = toString (1344 * scale);
      dropbox_fixed_size = toString (18 * scale);
      dropbox = "${dropbox-cli}/bin/dropbox";
      dropbox_status_icon = "${dropboxStatusIcon}";
      notify_send = "${libnotify}/bin/notify-send";
      # TODO: In Firefox launched by clicking yabar blocks,
      # XCURSOR_{THEME,SIZE} are not applied somehow.
      browser = "${xdg_utils}/bin/xdg-open";
      wifi_fixed_size = toString (201 * scale);
      wifi_switch = "${wifiSwitch}";
      termite = "${self.wrapped.termite}/bin/termite";
      nmtui = "${networkmanager}/bin/nmtui";
      bluetooth_fixed_size = toString (12 * scale);
      bluetoothctl = "${bluez}/bin/bluetoothctl";
      bluetooth_status_icon = "${bluetoothStatusIcon}";
      bluetooth_switch = "${bluetoothSwitch}";
      volume_fixed_size = toString (63 * scale);
      pactl = "${config.hardware.pulseaudio.package}/bin/pactl";
      pavucontrol = "${pavucontrol}/bin/pavucontrol";
      battery_fixed_size = toString (71 * scale);
      date_fixed_size = toString (124 * scale);
    });

    bspwm = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit (config.environment) colortheme;
    in
    substituteAll (colortheme // {
      src = ./data/config/bspwmrc;
      postInstall = "chmod +x $out";
      window_gap = toString (60 * scale);
        # 37 is derived from [bspwm window gap: 60] / [phi: 1.618]
        monocle_padding = toString (37 * scale);
    });

    sxhkd = super.runCommand "sxhkdrc" {} ''
      cp ${./data/config/sxhkdrc} $out
    '';
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
        src = ./data/config/rofi.conf;
        dpi = toString (96 * scale);
        font = "Source Code Pro Medium 13";
        terminal = "${self.wrapped.termite}/bin/termite";
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

    termite = with super;
    let
      inherit (config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ./data/config/termite;
        fonts = lib.concatStringsSep "\n" (map (s: "font = ${s}") [
          # The later declared, the more prioritized
          "Rounded Mgen+ 1m 13"
          "Source Code Pro 13"
        ]);
        hints_fonts = lib.concatStringsSep "\n" (map (s: "font = ${s}") [
          "Source Code Pro Bold 13"
        ]);
      });
    in
    buildEnv {
      name = "${termite.name}-wrapped";
      paths = [ termite ];
      pathsToLink = [ "/share" "/nix-support" ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        mkdir $out/bin
        makeWrapper ${termite}/bin/termite $out/bin/termite \
          --add-flags "--config ${configFile}"
      '';
    };

    zathura = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit(config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ./data/config/zathurarc;
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
