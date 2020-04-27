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
    gtk3 = self.callPackage ./gtk3/config.nix { inherit config; };

    dunst = self.callPackage ./dunst/config.nix { inherit config; };

    termite = self.callPackage ./termite/config.nix { inherit config; };

    yabar = self.callPackage ./yabar/config.nix {
      inherit config;
      termite = self.wrapped.termite;
    };

    bspwm = self.callPackage ./bspwm/config.nix { inherit config; };

    sxhkd = self.callPackage ./sxhkd/config.nix { inherit config; };
  };

  wrapped = {
    termite = self.callPackage ./termite/wrapper.nix {
      configDir = "${self.configFiles.termite}/etc/xdg";
    };

    feh = with super;
    let
      inherit (config.environment) colortheme;
    in
    buildEnv {
      name = "${feh.name}-wrapped";
      paths = [ feh.man ];
      buildInputs = [ makeWrapper ];
      postBuild = with colortheme; ''
        mkdir $out/bin
        makeWrapper ${feh.out}/bin/feh $out/bin/feh \
          --add-flags "--image-bg \"${black}\""
      '';
    };

    rofi = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit (config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ../data/config/rofi.conf;
        dpi = toString (96 * scale);
        font = "Source Code Pro Medium 13";
        terminal = "${termite}/bin/termite";
      });
    in
    buildEnv {
      name = "${rofi.name}-wrapped";
      paths = [ rofi ];
      pathsToLink = [ "/share" ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        mkdir $out/bin
        makeWrapper ${rofi}/bin/rofi $out/bin/rofi \
          --add-flags "-config ${configFile}"
        for path in ${rofi}/bin/*; do
          name="$(basename "$path")"
          [ "$name" != rofi ] && ln -s "$path" "$out/bin/$name"
        done
      '';
    };

    zathura = with super;
    let
      inherit (config.environment.hidpi) scale;
      inherit(config.environment) colortheme;
      configFile = substituteAll (colortheme // {
        src = ../data/config/zathurarc;
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
