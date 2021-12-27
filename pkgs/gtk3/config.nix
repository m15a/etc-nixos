{ config, substituteAll, runCommand }:

let
  inherit (config.environment.hidpi) scale;

  gtkCss = substituteAll {
    src = ./gtk.css;
  };

  settingsIni = substituteAll {
    src = ./settings.ini;
  };
in

runCommand "gtk-3.0" {} ''
  confd="$out/etc/xdg/gtk-3.0"
  install -D -m 444 "${gtkCss}" "$confd/gtk.css"
  install -D -m 444 "${settingsIni}" "$confd/settings.ini"
''
