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

    conky = self.callPackage ./conky/config.nix { inherit config; };

    dunst = self.callPackage ./dunst/config.nix { inherit config; };

    gtk3 = self.callPackage ./gtk3/config.nix { inherit config; };

    rofi = self.callPackage ./rofi/config.nix {
      inherit config;
      terminal = "${self.wrapped.alacritty}/bin/alacritty";
    };

    sxhkd = self.callPackage ./sxhkd/config.nix { inherit config; };

    alacritty = self.callPackage ./alacritty/config.nix { inherit config; };

    polybar = self.callPackage ./polybar/config.nix {
      inherit config;
      terminal = "${self.wrapped.alacritty}/bin/alacritty";
    };
  };

  wrapped = {
    feh = self.callPackage ./feh/wrapper.nix { inherit config; };

    rofi = self.callPackage ./rofi/wrapper.nix {
      configFile = self.configFiles.rofi;
    };

    alacritty = self.callPackage ./alacritty/wrapper.nix {
      configFile = self.configFiles.alacritty;
    };
  };
}
