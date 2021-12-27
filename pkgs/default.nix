{ config, ... }:

self: super:

{
  oomox-default-theme = self.callPackage ./oomox-default/theme.nix { inherit config; };
  oomox-default-icons = self.callPackage ./oomox-default/icons.nix { inherit config; };

  desktop-background = self.runCommand "desktop-background" {} ''
    cp ${../data/pixmaps/desktop_background.jpg} $out
  '';

  polybar = super.polybar.override {
    pulseSupport = true;
  };

  configFiles = {
    bspwm = self.callPackage ./bspwm/config.nix { inherit config; };

    fish = self.callPackage ./fish/config.nix { inherit config; };

    conky = self.callPackage ./conky/config.nix { inherit config; };

    dunst = self.callPackage ./dunst/config.nix { inherit config; };

    gtk3 = self.callPackage ./gtk3/config.nix { inherit config; };

    sxhkd = self.callPackage ./sxhkd/config.nix { inherit config; };

    alacritty = self.callPackage ./alacritty/config.nix { inherit config; };

    polybar = self.callPackage ./polybar/config.nix {
      inherit config;
      terminal = "${self.wrapped.alacritty}/bin/alacritty";
    };
  };

  rofi = super.rofi.overrideAttrs (old: {
    passthru = (old.passthru or {}) // rec {
      configFile = self.callPackage ./rofi/config.nix {
        inherit config;
        terminal = "${self.wrapped.alacritty}/bin/alacritty";
      };
      withConfig = self.callPackage ./rofi/wrapper.nix {
        inherit configFile;
      };
    };
  });

  wrapped = {
    feh = self.callPackage ./feh/wrapper.nix { inherit config; };

    alacritty = self.callPackage ./alacritty/wrapper.nix {
      configFile = self.configFiles.alacritty;
    };
  };
}
