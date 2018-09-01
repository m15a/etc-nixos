# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/btops.nix
    ./modules/dunst.nix
    ./modules/yabar.nix
    ./modules/hidpi.nix
    ./modules/lightlocker.nix
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
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "nmi_watchdog=0"
    ];

    tmpOnTmpfs = true;
  };

  hardware = {
    # cpu.intel.updateMicrocode = true;

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

  i18n = {
    # consoleColors = [
    #   # Srcery: https://github.com/srcery-colors/srcery-vim
    #   "1C1B19" "EF2F27" "519F50" "FBB829" "2C78BF" "E02C6D" "0AAEB3" "918175"
    #   "2D2C29" "F75341" "98BC37" "FED06E" "68A8E4" "FF5C8F" "53FDE9" "FCE8C3"
    # ];

    consoleKeyMap = "us";  # conflicts with consoleUseXkbConfig
    # consoleUseXkbConfig = true;

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
      fira-code
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
      "nixpkgs=/var/repos/nixpkgs"
      "nixos-config=/etc/nixos/${config.networking.hostName}.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio = true;
    };

    overlays = [ (self: super: {
      fehWrapper = with super; buildEnv {
        name = "${feh.name}-wrapper";
        paths = [ feh.man ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          mkdir $out/bin
          makeWrapper ${feh.out}/bin/feh $out/bin/feh \
            --add-flags "-B \"#1c1b19\""  # Srcery black
        '';
      };

      rofiWrapper = with super; let
        inherit (config.environment.hidpi) scale;
        configFile = substituteAll {
          src = ./data/config/rofi.conf;
          dpi = toString (96 * scale);
        };
      in buildEnv {
        name = "${rofi.name}-wrapper";
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

      termiteWrapper = with super; let
        configFile = substituteAll {
          src = ./data/config/termite;
          font_size = toString 13;
        };
      in buildEnv {
        name = "${termite.name}-wrapper";
        paths = [ termite ];
        pathsToLink = [ "/share" "/nix-support" ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          mkdir $out/bin
          makeWrapper ${termite}/bin/termite $out/bin/termite \
            --add-flags "--config ${configFile}"
        '';
      };

      zathuraWrapper = with super; let
        inherit (config.environment.hidpi) scale;
        configFile = substituteAll {
          src = ./data/config/zathurarc;
          page_padding = toString scale;
        };
        configDir = runCommand "zathura-config-dir" {} ''
          install -D -m 444 "${configFile}" "$out/zathurarc"
        '';
      in buildEnv {
        name = "${zathura.name}-wrapper";
        paths = [ zathura ];
        pathsToLink = [ "/share" ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          mkdir $out/bin
          makeWrapper ${zathura}/bin/zathura $out/bin/zathura \
            --add-flags "--config-dir ${configDir}"
        '';
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
  }) ];
  };

  environment = {
    systemPackages = with pkgs; let
      desktopPkgs = [
        libnotify
        fehWrapper
        rofiWrapper
        termiteWrapper
        pavucontrol
        zathuraWrapper
        dropbox-cli
        firefox-devedition-bin
      ] ++ gtkPkgs;
      gtkPkgs = [
        gtk3 # Required to use Emacs key bindings in GTK apps
        arc-theme
        papirus-icon-theme
        numix-cursor-theme
        gtk3Config
      ];
      miscPkgs = [
        scrot
      ];
    in desktopPkgs ++ miscPkgs;

    profileRelativeEnvVars = {
      MANPATH = [ "/man" "/share/man" ];
    };

    variables = {
      XCURSOR_THEME = "Numix";
      # Apps launched in ~/.xprofile need it if they use SVG icons.
      GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };

    shellAliases = {
      ls = "ls -Fh --color --time-style=long-iso";
      cp = "cp -i";
      mv = "mv -i";
      diff = "diff --color";
    };
  };

  programs = { # Shells
    bash.shellAliases = {
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
    };

    fish.enable = true;
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
        dx = let
          d = if x >= 0 then "+" else "";
          x = 15;
        in d + toString (x * scale);
        dy = let
          d = if y >= 0 then "+" else "";
          y = 30;
        in d + toString (y * scale);
      in "${width}x${height}${dx}${dy}";
      font_size = toString (13 * scale);
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
      showDropbox = pkgs.writeScript "show-dropbox" ''
        #!${pkgs.stdenv.shell}
        dropbox="${pkgs.dropbox-cli}/bin/dropbox"
        if "$dropbox" running; then
          # If true, confusingly, dropbox is not running!
        else
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
        ++ ( if config.networking.hostName == "louise"  # TODO: generalize
             then [ "wifi" "volume" "battery" ]
             else [ "volume" ]
           ));
      bottom_block_list = makeBlockList [ "workspace" ];
      date_fixed_size = toString (130 * scale);
      dropbox_fixed_size = toString (23 * scale);
      title_fixed_size = toString (1110 * scale);
      wifi_fixed_size = toString (193 * scale);
      volume_fixed_size = toString (65 * scale);
      battery_fixed_size = toString (75 * scale);
      workspace_fixed_size = toString (24 * scale);
      # TODO: In Firefox launched by clicking yabar blocks,
      # XCURSOR_{THEME,SIZE} are not applied somehow.
      firefox = "${pkgs.firefox-devedition-bin}/bin/firefox-devedition";
      dropbox = "${pkgs.dropbox-cli}/bin/dropbox";
      show_dropbox = "${showDropbox}";
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
    desktopManager.default = "none";
    windowManager.default = "bspwm";
    windowManager.bspwm.enable = true;
    windowManager.bspwm.configFile = let
      inherit (config.environment.hidpi) scale;
    in pkgs.substituteAll {
      src = ./data/config/bspwmrc;
      postInstall = "chmod +x $out";
      window_gap = toString (60 * scale);
    };
    windowManager.bspwm.sxhkd.configFile = pkgs.runCommand "sxhkdrc" {} ''
      cp ${./data/config/sxhkdrc} $out
    '';
    windowManager.bspwm.btops.enable = true;
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
      error-color = "#f75341"
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
    fadeDelta = 5;
    fadeSteps = [ "0.03" "0.03" ];

    shadow = true;
    shadowOpacity = "0.46";
    shadowOffsets = [ (-12 * scale) (-15 * scale) ];

    # glx with amdgpu does not work for now
    # https://github.com/chjj/compton/issues/477
    backend = if hasAmdgpu then "xrender" else "glx";
    vSync = if hasAmdgpu then "none" else "opengl-swc";

    extraOptions = ''
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      paint-on-overlay = true;
      use-ewmh-active-win = true;
      sw-opti = true;
      unredir-if-possible = true;
      detect-transient = true;
      detect-client-leader = true;
      blur-kern = "3x3gaussian";
      glx-no-stencil = true;
      glx-copy-from-front = false;
      glx-use-copysubbuffermesa = true;
      glx-no-rebind-pixmap = true;
      glx-swap-method = "buffer-age";
      shadow-radius = ${toString (22 * scale)};
      shadow-ignore-shaped = false;
      no-dnd-shadow = true;
      no-dock-shadow = true;
      clear-shadow = true;
    '';
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
  system.stateVersion = "18.03"; # Did you read the comment?
}
