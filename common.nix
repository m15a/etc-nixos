# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/btops.nix
    ./modules/colors
    ./modules/conky.nix
    ./modules/dropbox.nix
    ./modules/dunst.nix
    ./modules/hidpi.nix
    ./modules/light-locker.nix
    ./modules/polybar.nix
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
      # Serif
      newsreader
      shippori
      source-serif-pro
      source-han-serif-japanese

      # Sans serif
      raleway
      rounded-mgenplus # (1p)
      source-sans-pro
      source-han-sans-japanese

      # Monospace
      (nerdfonts.override { fonts = [ "Mononoki" ]; })
      # rounded-mgenplus (1m)
      source-code-pro
      source-han-code-jp

      # Emoji / Icons
      noto-fonts-emoji
    ];

    fontconfig.defaultFonts = {
      serif = [
        "Newsreader"
        "Shippori Mincho"
      ];
      sansSerif = [
        "Raleway"
        "Rounded Mgen+ 1p"
      ];
      monospace = [
        "mononoki Nerd Font"
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

    overlays = let
      nixpkgs-misc = builtins.fetchTarball {
        url = "https://github.com/mnacamura/nixpkgs-misc/archive/main.tar.gz";
      };
      nixpkgs-themix = builtins.fetchTarball {
        url = "https://github.com/mnacamura/nixpkgs-themix/archive/main.tar.gz";
      };
      nixpkgs-mozilla = builtins.fetchTarball {
        url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz";
      };
    in
    [
      (import ./pkgs { inherit config; })
      (import nixpkgs-misc)
      (import nixpkgs-themix)
      (import "${nixpkgs-mozilla}/firefox-overlay.nix")
    ];
  };

  environment = {
    colors.palette = config.environment.colors.palettes.srcery;

    systemPackages = with pkgs; [
      configFiles.fish
      latest.firefox-nightly-bin
      libnotify
      maim
      pavucontrol
      wrapped.feh
      wrapped.rofi
      wrapped.alacritty
    ] ++ [
      gtk3 # Required to use Emacs key bindings in GTK apps
      configFiles.gtk3
      oomox-default-theme
      oomox-default-icons
      paper-icon-theme
    ];

    pathsToLink = [
      "/etc/fish/conf.d"
      "/etc/fish/functions"
    ];

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
      # ls = "ls -Fh --color --time-style=long-iso";
      ls = null;
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

    dunst.enable = true;
    dunst.configFile = pkgs.configFiles.dunst;

    polybar.enable = true;
    polybar.configFile = pkgs.configFiles.polybar;

    fstrim.enable = true;

    devmon.enable = true;

    printing.enable = true;
    printing.drivers = [ pkgs.gutenprint ];
    colord.enable = true;  # required by CUPS
  };

  services.xserver = {
    enable = true;

    libinput.enable = true;
    libinput.touchpad = {
      accelSpeed = "1";
      disableWhileTyping = true;
      naturalScrolling = true;
      sendEventsMode = "disabled-on-external-mouse";
    };
    libinput.mouse = {
      accelProfile = "flat";
      # 4k display, scale 1.5 => cursor moving from left to right: ~3inch
      accelSpeed = "1";
    };

    inputClassSections = [
      ''
        Identifier       "HHKB Professional"
        MatchIsKeyboard  "on"
        MatchProduct     "Topre Corporation HHKB Professional"

        Option "XkbModel"    "hhk"
        Option "XkbLayout"   "us"
        Option "XkbVariant"  ""
        Option "XkbOptions"  "terminate:ctrl_alt_bksp"
      ''
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

    displayManager.sessionCommands = ''
      ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
      ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${pkgs.desktop-background}
    '';

    displayManager.lightdm = {
      enable = true;

      # TODO: Here background is not scaled while session background above is scaled.
      background = pkgs.desktop-background;

      greeters.mini = {
        enable = true;
        user = "mnacamura";
        extraConfig = let
          inherit (config.environment.hidpi) scale;
          colors = config.environment.colors.hex;
        in with colors; ''
          [greeter]
          show-password-label = false
          invalid-password-text = beep! beep!
          [greeter-theme]
          font = monospace Bold
          font-size = 13pt
          text-color = "${term_fg}"
          error-color = "${term_fg}"
          window-color = "${sel_bg}"
          border-width = 0
          layout-space = ${toString (19 * scale)}
          password-color = "${term_fg}"
          password-background-color = "${term_bg}"
          password-border-radius = 0
          password-border-width = 0px
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
      btops.configFile = pkgs.writeText "btops-config.toml" ''
        min = 4
        max = 10
        renamers = [ "numeric" ]
      '';
    };
  };

  services.picom = let
    inherit (config.environment.hidpi) scale;
    hasAmdgpu = lib.any (d: d == "amdgpu") config.services.xserver.videoDrivers;
  in {
    enable = true;

    fade = true;
    fadeDelta = 8;
    fadeSteps = [ 0.056 0.06 ];

    # glx with amdgpu does not work for now.
    # https://github.com/chjj/compton/issues/477
    backend = if hasAmdgpu then "xrender" else "glx";
    vSync = true;

    settings = {
      frame-opacity = "0.0";
      inactive-opacity-override = false;

      detect-client-leader = true;
      detect-transient = true;
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
