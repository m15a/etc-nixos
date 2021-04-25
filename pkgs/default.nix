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

  polybar = super.polybar.override {
    pulseSupport = true;
  };

  rounded-mgenplus = with self;
  let
    pname = "rounded-mgenplus";
    version = "20150602";
  in fetchzip rec {
    name = "${pname}-${version}";
    url = "https://osdn.jp/downloads/users/8/8598/${name}.7z";
    postFetch = ''
      ${libarchive}/bin/bsdtar x $downloadedFile
      install -m 444 -D -t $out/share/fonts/${pname} ${pname}-*.ttf
    '';
    sha256 = "0vwdknagdrl5dqwpb1x5lxkbfgvbx8dpg7cb6yamgz71831l05v1";
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
