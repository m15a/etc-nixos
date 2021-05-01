{ config, ... }:

self: super:
{
  adapta-gtk-theme-colorpack = self.callPackage ./adapta-gtk-theme-colorpack {};

  adapta-gtk-theme-custom = let
    inherit (config.environment) colortheme;
  in with colortheme.hex;
  self.callPackage ./adapta-gtk-theme/custom.nix {
    selectionColor = brorange;
    accentColor = brgreen;
    suggestionColor = brorange;
    destructionColor = red;
    enableParallel = true;
  };

  desktop-background = self.runCommand "desktop-background" {} ''
    cp ${../data/pixmaps/desktop_background.jpg} $out
  '';

  polybar = super.polybar.override {
    pulseSupport = true;
  };

  yabar-unstable = super.yabar-unstable.overrideAttrs (old: rec {
    version = "2019-03-28";
    src = self.fetchFromGitHub {
      owner = "geommer";
      repo = "yabar";
      rev = "a0d3fdfed992149b741eb8fcf53f02b5d1a6142e";
      sha256 = "01igivi2s96xxgy08cbhmvqcfq15rckh258gjy1iygkc8fzzlxjw";
    };
  });

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

    polybar = self.callPackage ./polybar/config.nix {
      inherit config;
      termite = self.wrapped.termite;
    };

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
