{ config, lib, writeText, substituteAll, runCommand }:

let
  inherit (config.environment) colortheme;

  # TODO: Somehow this works only in ~/.config/gtk-3.0/gtk.css
  gtkCss = writeText "gtk.css" ''
    .termite {
        padding: 8px;
    }
  '';

  configFile = substituteAll (colortheme.hex // {
    src = ../../data/etc/xdg/termite/config;

    fonts = lib.concatMapStringsSep "\n" (s: "font = ${s}") [
      # The later declared, the more prioritized
      # "Rounded Mgen+ 1m 13"  # in the fallback fonts
      "mononoki Regular 12"
    ];

    hints_fonts = lib.concatMapStringsSep "\n" (s: "font = ${s}") [
      "mononoki Bold 12"
    ];
  });
in

runCommand "termite-config" {} ''
  install -D -m 444 "${gtkCss}" "$out/etc/xdg/gtk-3.0/gtk.css"
  install -D -m 444 "${configFile}" "$out/etc/xdg/termite/config"
''
