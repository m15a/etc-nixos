{ config, lib, ... }:

final: prev:

{
  lightdm-mini-greeter = final.callPackage ./lightdm-mini-greeter {
    origin = prev.lightdm-mini-greeter;
  };

  oomox-default-theme = final.callPackage ./oomox-default/theme.nix { inherit config; };
  oomox-default-icons = final.callPackage ./oomox-default/icons.nix { inherit config; };

  desktop-background = final.callPackage ./desktop-background {};

  maim = final.callPackage ./maim/wrapper.nix {
    maim = prev.maim;
  };

  polybar = prev.polybar.override {
    pulseSupport = true;
  };

  zathura = final.callPackage ./zathura/wrapper.nix {
    zathura = prev.zathura;
    configFile = final.configFiles.zathura;
  };

  inherit (final.callPackage ./fish/lib.nix {})
  writeFishScript
  writeFishScriptBin
  writeFishApplication;

  configFiles = lib.recurseIntoAttrs {
    alacritty = final.callPackage ./alacritty/config.nix { inherit config; };

    bspwm = final.callPackage ./bspwm/config.nix { inherit config; };

    conky = final.callPackage ./conky/config.nix { inherit config; };

    dunst = final.callPackage ./dunst/config.nix { inherit config; };

    fish = final.callPackage ./fish/config.nix { inherit config; };

    gtk3 = final.callPackage ./gtk3/config.nix { inherit config; };

    polybar = final.callPackage ./polybar/config.nix {
      inherit config;
      terminal = "${config.programs.alacritty.wrappedPackage}/bin/alacritty";
    };

    rofi = final.callPackage ./rofi/config.nix {
      inherit config;
      terminal = "${config.programs.alacritty.wrappedPackage}/bin/alacritty";
    };

    sxhkd = final.callPackage ./sxhkd/config.nix { inherit config; };

    zathura = final.callPackage ./zathura/config.nix { inherit config; };
  };
}
