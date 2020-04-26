{ config, lib, substituteAll, runCommand }:

let
  inherit (config.environment) colortheme;

  configFile = substituteAll (colortheme // {
    src = ../../data/etc/xdg/termite/config;

    fonts = lib.concatStringsSep "\n" (map (s: "font = ${s}") [
      # The later declared, the more prioritized
      # "Rounded Mgen+ 1m 13"  # in the fallback fonts
      "Source Code Pro 13"
    ]);

    hints_fonts = lib.concatStringsSep "\n" (map (s: "font = ${s}") [
      "Source Code Pro Bold 13"
    ]);
  });
in

runCommand "termite-config" {} ''
  install -D -m 444 ${configFile} "$out/etc/xdg/termite/config"
''
