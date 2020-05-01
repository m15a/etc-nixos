{ config, ... }:

self: super:
{
  adapta-gtk-theme-colorpack = self.callPackage ./adapta-gtk-theme-colorpack {};

  adapta-gtk-theme-custom = let
    colortheme = self.lib.mapAttrs (_: c: c.hex) config.environment.colortheme.palette;
  in with colortheme;
  self.callPackage ./adapta-gtk-theme/custom.nix {
    selectionColor = orange;
    accentColor = brorange;
    suggestionColor = brorange;
    destructionColor = red;
    enableParallel = true;
    enableTelegram = true;
  };

  configFiles = {
    bspwm = self.callPackage ./bspwm/config.nix { inherit config; };

    dunst = self.callPackage ./dunst/config.nix { inherit config; };

    gtk3 = self.callPackage ./gtk3/config.nix { inherit config; };

    rofi = self.callPackage ./rofi/config.nix {
      inherit config;
      termite = self.wrapped.termite;
    };

    sxhkd = self.callPackage ./sxhkd/config.nix { inherit config; };

    termite = self.callPackage ./termite/config.nix { inherit config; };

    yabar = self.callPackage ./yabar/config.nix {
      inherit config;
      termite = self.wrapped.termite;
    };
  };

  wrapped = {
    feh = self.callPackage ./feh/wrapper.nix { inherit config; };

    rofi = self.callPackage ./rofi/wrapper.nix {
      configFile = self.configFiles.rofi;
    };

    termite = self.callPackage ./termite/wrapper.nix {
      configDir = "${self.configFiles.termite}/etc/xdg";
    };
  };
}
