# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/btops.nix
    ./modules/colortheme.nix
    ./modules/dropbox.nix
    ./modules/dunst.nix
    ./modules/hidpi.nix
    ./modules/libinput.nix
    ./modules/light-locker.nix
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

  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  fonts = {
    fonts = with pkgs; [
      source-serif-pro
      source-sans-pro
      source-code-pro
      source-han-serif-japanese
      source-han-sans-japanese
      source-han-code-jp
      rounded-mgenplus
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
        "Rounded Mgen+ 1c"
      ];
      monospace = [
        "Source Code Pro"
        "Rounded Mgen+ 1m"
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
      (import ./pkgs { inherit config; })
    ];
  };

  environment = {
    colortheme = {
      # Srcery: https://github.com/srcery-colors/srcery-vim
      black     = "#1C1B19";
      red       = "#EF2F27";
      green     = "#519F50";
      yellow    = "#FBB829";
      blue      = "#2C78BF";
      magenta   = "#E02C6D";
      cyan      = "#0AAEB3";
      white     = "#918175";
      brblack   = "#2D2C29";
      brred     = "#F75341";
      brgreen   = "#98BC37";
      bryellow  = "#FED06E";
      brblue    = "#68A8E4";
      brmagenta = "#FF5C8F";
      brcyan    = "#53FDE9";
      brwhite   = "#FCE8C3";
      orange    = "#D75F00";
      brorange  = "#FF8700";
      hardblack = "#121212";
      xgray1    = "#262626";
      xgray2    = "#303030";
      xgray3    = "#3A3A3A";
      xgray4    = "#444444";
      xgray5    = "#4E4E4E";
      xgray6    = "#585858";
    };

    systemPackages = with pkgs; [
      # firefox-devedition-bin
      libnotify
      maim
      pavucontrol
      wrapped.feh
      wrapped.rofi
      wrapped.termite
      wrapped.zathura
    ] ++ [
      gtk3 # Required to use Emacs key bindings in GTK apps
      adapta-gtk-theme-custom
      paper-icon-theme
      papirus-icon-theme
    ];

    etc = with pkgs.configFiles; {
      "xdg/gtk-3.0/gtk.css".source = "${gtk3}/etc/xdg/gtk-3.0/gtk.css";
      "xdg/gtk-3.0/settings.ini".source = "${gtk3}/etc/xdg/gtk-3.0/settings.ini";
    };

    profileRelativeEnvVars = {
      MANPATH = [ "/man" "/share/man" ];
    };

    variables = {
      XCURSOR_THEME = "Paper";
      # Apps launched in ~/.xprofile need it if they use SVG icons.
      GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
      PAGER = "less";
      LESS = "-R -ig -j.5";
      LESSCHARSET = "utf-8";
    };

    shellAliases = {
      ls = "ls -Fh --color --time-style=long-iso";
      l = "ls";
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
      cp = "cp -i";
      mv = "mv -i";
      diff = "diff --color";
    };
  };

  programs = {
    fish.enable = true;
    fish.shellAliases = {
      l = null;
      la = null;
      ll = null;
      lla = null;
    };
    fish.shellInit = ''
      umask 077
    '';
    fish.interactiveShellInit = ''
      abbr --add l 'ls'
      abbr --add la 'ls -a'
      abbr --add ll 'ls -l'
      abbr --add lla 'ls -la'
      abbr --add h history
      abbr --add d  dirh
      abbr --add nd nextd
      abbr --add pd prevd
    '';

    dconf.enable = true;

    light-locker.enable = true;
    light-locker.lockAfterScreensaver = 10;

    vim.defaultEditor = true;
  };

  services = {
    chrony.enable = true;

    dropbox.enable = true;

    dunst.enable = true;
    dunst.configFile = pkgs.configFiles.dunst;

    yabar.enable = true;
    yabar.package = pkgs.yabar-unstable;
    yabar.configFile = pkgs.configFiles.yabar;

    fstrim.enable = true;

    devmon.enable = true;

    printing.enable = true;
    printing.drivers = [ pkgs.gutenprint ];
    colord.enable = true;  # required by CUPS
  };

  services.xserver = {
    enable = true;

    myLibinput.enable = true;

    inputClassSections = [
      ''
        Identifier       "HHKB Professional BT"
        MatchIsKeyboard  "on"
        MatchProduct     "HHKB-BT"

        Option "XkbModel"    "hhk"
        Option "XkbLayout"   "us"
        Option "XkbVariant"  ""
        Option "XkbOptions"  "terminate:ctrl_alt_bksp"
      ''
    ];

    displayManager.sessionCommands = let
      backgroundImage = pkgs.runCommand "desktop-background" {} ''
        cp ${./data/pixmaps/desktop_background.jpg} $out
      '';
    in ''
      ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
      ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${backgroundImage}
    '';

    displayManager.lightdm = {
      enable = true;

      background = let
        backgroundImage = pkgs.runCommand "login-background" {} ''
          cp ${./data/pixmaps/login_background.jpg} $out
        '';
      in "${backgroundImage}";

      greeters.mini = {
        enable = true;
        user = "mnacamura";
        extraConfig = let
          inherit (config.environment) colortheme;
        in with colortheme; ''
          [greeter-theme]
          font = Source Code Pro Medium
          font-size = 13pt
          text-color = "${brwhite}"
          error-color = "${brwhite}"
          window-color = "${brorange}"
          border-width = 0
          layout-space = 40
          password-color = "${brwhite}"
          password-background-color = "${black}"
        '';
      };
    };

    # Enable bspwm environment.
    displayManager.defaultSession = "none+bspwm";
    windowManager.bspwm = {
      enable = true;
      configFile = pkgs.configFiles.bspwm;
      sxhkd.configFile = pkgs.configFiles.sxhkd;
      btops.enable = true;
    };
  };

  services.picom = let
    inherit (config.environment.hidpi) scale;
    hasAmdgpu = lib.any (d: d == "amdgpu") config.services.xserver.videoDrivers;
  in {
    enable = true;

    fade = true;
    fadeDelta = 8;
    fadeSteps = [ "0.056" "0.06" ];

    activeOpacity = "0.92";
    inactiveOpacity = "0.68";
    shadowOpacity = "0.36";
    opacityRules = [
      "100:class_g *?= 'Firefox'"
      "100:class_g *?= 'Nightly'"
      "92:class_g ?= 'Rofi'"
      "100:class_g ?= 'Steam'"
      "100:class_g ?= 'Zathura'"
      "100:class_g ?= 'Gimp'"
      "100:class_g ?= 'Inkscape'"
      "100:class_g ?= 'zoom'"
      # 100% opacity for fullscreen
      "100:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_FULLSCREEN'"
      "100:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_FULLSCREEN'"
      "100:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_FULLSCREEN'"
      "100:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_FULLSCREEN'"
      "100:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_FULLSCREEN'"
    ];

    shadow = true;
    shadowOffsets = map (x: x * scale) [ (-10) (-10) ];

    wintypes = {
      dock = { shadow = false; };
      dropdown_menu = { opacity = 0.92; };
      popup_menu = { opacity = 0.92; };
    };

    # glx with amdgpu does not work for now.
    # https://github.com/chjj/compton/issues/477
    backend = if hasAmdgpu then "xrender" else "glx";
    vSync = true;

    settings = {
      shadow-radius = 38;

      frame-opacity = "0.0";
      inactive-opacity-override = false;

      detect-client-leader = false;
      detect-transient = false;
      unredir-if-possible = true;
      use-ewmh-active-win = true;

      glx-copy-from-front = false;
      glx-no-rebind-pixmap = true;
      glx-no-stencil = true;
    };
  };

  users.users.mnacamura = {
    description = "Mitsuhiro Nakamura";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = "${pkgs.fish}/bin/fish";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
