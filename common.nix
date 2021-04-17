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
      mononoki
      source-han-serif-japanese
      source-han-sans-japanese
      source-han-code-jp
      rounded-mgenplus
      noto-fonts-emoji
      emojione
      font-awesome-ttf
    ];

    fontconfig.defaultFonts = {
      serif = [
        "Source Serif Pro"
        "Source Han Serif"
      ];
      sansSerif = [
        "Source Sans Pro"
        "Rounded Mgen+ 1c"
      ];
      monospace = [
        "mononoki"
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
    colortheme.palette = {
      # Srcery: https://github.com/srcery-colors/srcery-vim
      black     = { nr =   0; hex = "#1C1B19"; };
      red       = { nr =   1; hex = "#EF2F27"; };
      green     = { nr =   2; hex = "#519F50"; };
      yellow    = { nr =   3; hex = "#FBB829"; };
      blue      = { nr =   4; hex = "#2C78BF"; };
      magenta   = { nr =   5; hex = "#E02C6D"; };
      cyan      = { nr =   6; hex = "#0AAEB3"; };
      white     = { nr =   7; hex = "#D0BFA1"; };
      brblack   = { nr =   8; hex = "#918175"; };
      brred     = { nr =   9; hex = "#F75341"; };
      brgreen   = { nr =  10; hex = "#98BC37"; };
      bryellow  = { nr =  11; hex = "#FED06E"; };
      brblue    = { nr =  12; hex = "#68A8E4"; };
      brmagenta = { nr =  13; hex = "#FF5C8F"; };
      brcyan    = { nr =  14; hex = "#53FDE9"; };
      brwhite   = { nr =  15; hex = "#FCE8C3"; };
      orange    = { nr = 166; hex = "#D75F00"; };
      brorange  = { nr = 208; hex = "#FF8700"; };
      hardblack = { nr = 233; hex = "#121212"; };
      xgray1    = { nr = 235; hex = "#262626"; };
      xgray2    = { nr = 236; hex = "#303030"; };
      xgray3    = { nr = 237; hex = "#3A3A3A"; };
      xgray4    = { nr = 238; hex = "#444444"; };
      xgray5    = { nr = 239; hex = "#4E4E4E"; };
      xgray6    = { nr = 240; hex = "#585858"; };
    };

    systemPackages = with pkgs; [
      # firefox-devedition-bin
      libnotify
      maim
      pavucontrol
      wrapped.feh
      wrapped.rofi
      wrapped.termite
    ] ++ [
      gtk3 # Required to use Emacs key bindings in GTK apps
      configFiles.gtk3
      adapta-gtk-theme-custom
      paper-icon-theme
      papirus-icon-theme
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

  # Hot fix for recent bluetooth failing, see https://github.com/NixOS/nixpkgs/pull/113600.
  systemd.services.bluetooth.serviceConfig.ExecStart = let
    cfg = config.hardware.bluetooth;
    hasDisabledPlugins = builtins.length cfg.disabledPlugins > 0;
    args = [ "-f" "/etc/bluetooth/main.conf" ] ++
      lib.optional hasDisabledPlugins "--noplugin=${lib.concatStringsSep "," cfg.disabledPlugins}";
  in
  [
    ""
    "${cfg.package}/libexec/bluetooth/bluetoothd ${lib.escapeShellArgs args}"
    ""
  ];

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
        Identifier       "HHKB Professional"
        MatchIsKeyboard  "on"
        MatchProduct     "HHKB Professional"

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
          inherit (config.environment.hidpi) scale;
          colortheme = lib.mapAttrs (_: c: c.hex) config.environment.colortheme.palette; 
        in with colortheme; ''
          [greeter]
          show-password-label = false
          invalid-password-text = beep! beep!
          [greeter-theme]
          font = mononoki Bold
          font-size = 13pt
          text-color = "${brwhite}"
          error-color = "${brwhite}"
          window-color = "${brorange}"
          border-width = 0
          layout-space = ${toString (22 * scale)}
          password-color = "${brwhite}"
          password-background-color = "${black}"
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
