{ config, ... }:

self: super:
{
  adapta-gtk-theme-colorpack = self.callPackage ./adapta-gtk-theme-colorpack {};

  adapta-gtk-theme-custom = with config.environment.colortheme;
  self.callPackage ./adapta-gtk-theme/custom.nix {
    selectionColor = brorange;
    accentColor = orange;
    suggestionColor = orange;
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
    termite = self.callPackage ./termite/wrapper.nix {
      configDir = "${self.configFiles.termite}/etc/xdg";
    };

    feh = self.callPackage ./feh/wrapper.nix { inherit config; };

    rofi = self.callPackage ./rofi/wrapper.nix {
      configFile = self.configFiles.rofi;
    };

    zathura = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit(config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ../data/config/zathura/zathurarc;
        font = "Source Code Pro 13";
        page_padding = toString scale;
      });
      configDir = runCommand "zathura-config-dir" {} ''
        install -D -m 444 "${configFile}" "$out/zathurarc"
      '';
    in
    buildEnv {
      name = "${zathura.name}-wrapped";
      paths = [ zathura ];
      pathsToLink = [ "/share" ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        mkdir $out/bin
        makeWrapper ${zathura}/bin/zathura $out/bin/zathura \
          --add-flags "--config-dir ${configDir}"
      '';
    };
  };
}
