# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/btops.nix
    ./modules/dunst.nix
    ./modules/hidpi.nix
    ./modules/lightlocker.nix
    ./modules/yabar.nix
  ];

  fileSystems = let
    # Mount options for Btrfs on SSD
    commonMountOptions = [
      "commit=60"
      "compress=lzo"
      "defaults"
      "noatime"
    ];
  in {
    "/".options = commonMountOptions;
    "/nix".options = commonMountOptions;
    "/var".options = commonMountOptions;
    "/home".options = commonMountOptions;

    # Required as Dropbox only supports ext4 on Linux.
    "/home/mnacamura/Dropbox" = {
      device = "/var/dropbox/mnacamura.img";
      fsType = "ext4";
      options = [ "loop" "defaults" "noatime" ];
    };
  };

  boot = {
    extraModprobeConfig = ''
      # https://github.com/NixOS/nixpkgs/issues/57053
      options cfg80211 ieee80211_regdom="JP"
    '';

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "nmi_watchdog=0"
    ];

    tmpOnTmpfs = true;
  };

  hardware = {
    # platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
    firmware = with pkgs; [ wireless-regdb ];

    bluetooth.enable = true;

    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  sound = {
    # ALSA problem: Failed to find module 'snd_pcm_oss'
    enableOSSEmulation = false;
  };

  networking = {
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Tokyo";

  console = {
    # colors = [
    #   # Srcery: https://github.com/srcery-colors/srcery-vim
    #   "1C1B19" "EF2F27" "519F50" "FBB829" "2C78BF" "E02C6D" "0AAEB3" "918175"
    #   "2D2C29" "F75341" "98BC37" "FED06E" "68A8E4" "FF5C8F" "53FDE9" "FCE8C3"
    # ];

    useXkbConfig = true;
  };

  i18n = {
    defaultLocale = "ja_JP.UTF-8";

    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };
  };

  fonts = {
    fonts = with pkgs; [
      source-serif-pro
      source-sans-pro
      source-code-pro
      source-han-serif-japanese
      source-han-sans-japanese
      noto-fonts-emoji
      font-awesome-ttf
    ];

    fontconfig.defaultFonts = {
      serif = [
        "Source Serif Pro"
        "Source Han Serif JP"
      ];
      sansSerif = [
        "Source Sans Pro"
        "Source Han Sans JP"
      ];
      monospace = [
        "Source Code Pro"
      ];
    };
  };

  nix = {
    trustedUsers = [ "@wheel" ];

    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/${config.networking.hostName}.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio = true;
    };

    overlays = [
      (self: super: {
        wrapped = {
          feh = with super; buildEnv {
            name = "${feh.name}-wrapped";
            paths = [ feh.man ];
            buildInputs = [ makeWrapper ];
            postBuild = ''
              mkdir $out/bin
              makeWrapper ${feh.out}/bin/feh $out/bin/feh \
                --add-flags "--image-bg \"#1c1b19\""  # Srcery black
            '';
          };

          rofi = with super; let
            inherit (config.environment.hidpi) scale;
            configFile = substituteAll {
              src = ./data/config/rofi.conf;
              dpi = toString (96 * scale);
              font_size = toString 13;
            };
          in buildEnv {
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

          termite = with super; let
            configFile = substituteAll {
              src = ./data/config/termite;
              font_size = toString 13;
            };
          in buildEnv {
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

          zathura = with super; let
            inherit (config.environment.hidpi) scale;
            configFile = substituteAll {
              src = ./data/config/zathurarc;
              font_size = toString 13;
              page_padding = toString scale;
            };
            configDir = runCommand "zathura-config-dir" {} ''
              install -D -m 444 "${configFile}" "$out/zathurarc"
            '';
          in buildEnv {
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

        gtk3Config = with super; let
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
      })
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      dropbox-cli
      firefox-devedition-bin
      libnotify
      pavucontrol
      wrapped.feh
      wrapped.rofi
      wrapped.termite
      wrapped.zathura
    ] ++ [
      gtk3 # Required to use Emacs key bindings in GTK apps
      gtk3Config
      arc-theme
      numix-cursor-theme
      papirus-icon-theme
    ];

    profileRelativeEnvVars = {
      MANPATH = [ "/man" "/share/man" ];
    };

    variables = {
      XCURSOR_THEME = "Numix-Cursor";
      # Apps launched in ~/.xprofile need it if they use SVG icons.
      GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };

    shellAliases = {
      ls = "ls -Fh --color --time-style=long-iso";
      l = null;
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
      cp = "cp -i";
      mv = "mv -i";
      diff = "diff --color";
    };
  };

  programs = { # Shells
    fish.enable = true;
    fish.shellAliases = {
      la = null;
      ll = null;
      lla = null;
    };
    fish.shellInit = ''
      umask 077
    '';
    fish.interactiveShellInit = ''
      abbr --add la 'ls -a'
      abbr --add ll 'ls -l'
      abbr --add lla 'ls -la'
      abbr --add h history
      abbr --add d  dirh
      abbr --add nd nextd
      abbr --add pd prevd
    '';
  } // { # Others
    dconf.enable = true;

    lightlocker.enable = true;
    lightlocker.lockAfterScreensaver = 10;

    vim.defaultEditor = true;
  };

  services = {
    chrony.enable = true;

    dunst.enable = true;
    dunst.configFile = let
      inherit (config.environment.hidpi) scale;
    in pkgs.substituteAll {
      src = ./data/config/dunstrc;
      geometry = let
        width = toString (450 * scale);
        height = toString 5;
        d = x:
        "${if x >= 0 then "+" else ""}${toString (x * scale)}";
      in "${width}x${height}${d 15}${d 30}";
      font_size = toString 13;
      max_icon_size = toString (24 * scale);
      icon_path = let
        s = toString (24 * scale);
        path = "${pkgs.papirus-icon-theme}/share/icons/Papirus";
      in lib.concatStringsSep ":"
      (map (cat: "${path}/${s}x${s}/${cat}") [ "status" "devices" "apps" ]);
      padding = toString (3 * scale);
      horizontal_padding = toString (5 * scale);
    };

    yabar.enable = true;
    yabar.package = pkgs.yabar-unstable;
    yabar.configFile = let
      inherit (config.environment.hidpi) scale;
      dropboxStatusIcon = pkgs.writeScript "dropbox-status-icon" ''
        #!${pkgs.runtimeShell}
        dropbox="${pkgs.dropbox-cli}/bin/dropbox"
        # If status = 0, confusingly, dropbox is not running!
        "$dropbox" running
        if [[ $? -ne 0 ]]; then
          status=$("$dropbox" status 2>/dev/null)
          if [[ "$status" = 'Up to date' || "$status" = '最新の状態' ]]; then
            echo ''
          else
            echo ''
          fi
        fi
      '';
      makeBlockList = blockNames: let
        contents = lib.concatStringsSep ", " (map (b: "\"${b}\"") blockNames);
      in "[ ${contents} ]";
    in pkgs.substituteAll {
      src = ./data/config/yabar.conf;
      height = toString (23 * scale);
      slack_size = toString (5 * scale);
      font_size = toString (13 * scale);
      top_block_list = makeBlockList ([ "date" "dropbox" "title" ]
        ++ ( if config.networking.hostName == "louise"  # TODO: Generalize it.
             then [ "wifi" "volume" "battery" ]
             else [ "volume" ]
           ));
      bottom_block_list = makeBlockList [ "workspace" ];
      date_fixed_size = toString (130 * scale);
      dropbox_fixed_size = toString (30 * scale);
      title_fixed_size = toString (1110 * scale);
      wifi_fixed_size = toString (210 * scale);
      volume_fixed_size = toString (80 * scale);
      battery_fixed_size = toString (90 * scale);
      workspace_fixed_size = toString (30 * scale);
      # TODO: In Firefox launched by clicking yabar blocks,
      # XCURSOR_{THEME,SIZE} are not applied somehow.
      firefox = "${pkgs.firefox-devedition-bin}/bin/firefox-devedition";
      dropbox = "${pkgs.dropbox-cli}/bin/dropbox";
      dropbox_status_icon = "${dropboxStatusIcon}";
      notify_send = "${pkgs.libnotify}/bin/notify-send";
      termite = "${pkgs.termite}/bin/termite";
      nmtui = "${pkgs.networkmanager}/bin/nmtui";
      pactl = "${config.hardware.pulseaudio.package}/bin/pactl";
      pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    };

    fstrim.enable = true;

    devmon.enable = true;

    printing.enable = true;
    printing.drivers = [ pkgs.gutenprint ];
    colord.enable = true;  # required by CUPS
  };

  services.xserver = {
    enable = true;

    layout = "us";

    # Enable bspwm environment.
    displayManager.defaultSession = "none+bspwm";
    windowManager = {
      bspwm.enable = true;
      bspwm.configFile = let
        inherit (config.environment.hidpi) scale;
      in pkgs.substituteAll {
        src = ./data/config/bspwmrc;
        postInstall = "chmod +x $out";
        window_gap = toString (60 * scale);
      };
      bspwm.sxhkd.configFile = pkgs.runCommand "sxhkdrc" {} ''
        cp ${./data/config/sxhkdrc} $out
      '';
      bspwm.btops.enable = true;
    };
  };

  services.xserver.displayManager.lightdm = {
    enable = true;

    background = let
      backgroundImage = pkgs.runCommand "login-background" {} ''
        cp ${./data/pixmaps/login_background.jpg} $out
      '';
    in "${backgroundImage}";

    greeters.mini.enable = true;
    greeters.mini.user = "mnacamura";
    greeters.mini.extraConfig = ''
      [greeter-theme]
      font = Source Code Pro Medium
      font-size = 13pt
      text-color = "#fce8c3"
      error-color = "#fce8c3"
      window-color = "#d75f00"
      border-width = 0
      layout-space = 40
      password-color = "#fce8c3"
      password-background-color = "#1c1b19"
    '';
  };

  services.xserver.displayManager.sessionCommands = let
    backgroundImage = pkgs.runCommand "desktop-background" {} ''
      cp ${./data/pixmaps/desktop_background.jpg} $out
    '';
  in ''
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
    ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${backgroundImage}
  '';

  services.compton = let
    inherit (config.environment.hidpi) scale;
    hasAmdgpu = lib.any (d: d == "amdgpu") config.services.xserver.videoDrivers;
  in {
    enable = true;

    fade = true;
    fadeSteps = [ "0.056" "0.06" ];

    shadow = false;

    activeOpacity = "1.0";
    inactiveOpacity = "0.8";

    # glx with amdgpu does not work for now.
    # https://github.com/chjj/compton/issues/477
    backend = if hasAmdgpu then "xrender" else "glx";
    vSync = true;

    settings = {
      frame-opacity = "0.0";
      inactive-opacity-override = true;
      use-ewmh-active-win = true;
      unredir-if-possible = true;
      detect-transient = true;
      detect-client-leader = true;

      ## wintypes has been set by `menuOpacity` before putting `extraConfig`
      ## and this duplicated wintypes setting fails.
      ## See https://github.com/NixOS/nixpkgs/pull/61681.
      # wintypes = {
      #   tooltip = { fade = false; };
      #   dock = { fade = false; };
      #   popup_menu = { fade = false; };
      #   dropdown_menu = { fade = false; };
      # };

      glx-no-stencil = true;
      glx-copy-from-front = false;
      glx-no-rebind-pixmap = true;
    };
  };

  users.users.mnacamura = {
    description = "Mitsuhiro Nakamura";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = "/run/current-system/sw/bin/fish";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
