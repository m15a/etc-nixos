{ config, ... }:

final: prev:

{
  oomox-default-theme = final.callPackage ./oomox-default/theme.nix { inherit config; };
  oomox-default-icons = final.callPackage ./oomox-default/icons.nix { inherit config; };

  desktop-background = final.runCommand "desktop-background" {} ''
    cp ${../data/pixmaps/desktop_background.jpg} $out
  '';

  polybar = prev.polybar.override {
    pulseSupport = true;
  };

  configFiles = {
    bspwm = final.callPackage ./bspwm/config.nix { inherit config; };

    fish = final.callPackage ./fish/config.nix { inherit config; };

    conky = final.callPackage ./conky/config.nix { inherit config; };

    gtk3 = final.callPackage ./gtk3/config.nix { inherit config; };

    sxhkd = final.callPackage ./sxhkd/config.nix { inherit config; };

    alacritty = final.callPackage ./alacritty/config.nix { inherit config; };

    polybar = final.callPackage ./polybar/config.nix {
      inherit config;
      terminal = "${final.wrapped.alacritty}/bin/alacritty";
    };
  };

  dunst = prev.dunst.overrideAttrs (old: {
    passthru = (old.passthru or {}) // {
      configFile = final.callPackage ./dunst/config.nix {
        inherit config;
      };
    };
  });

  rofi = prev.rofi.overrideAttrs (old: {
    passthru = (old.passthru or {}) // rec {
      configFile = final.callPackage ./rofi/config.nix {
        inherit config;
        terminal = "${final.wrapped.alacritty}/bin/alacritty";
      };
    };
  });

  wrapped = {
    feh = final.callPackage ./feh/wrapper.nix { inherit config; };

    alacritty = final.callPackage ./alacritty/wrapper.nix {
      configFile = final.configFiles.alacritty;
    };
  };
}
