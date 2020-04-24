{ config, substituteAll, runCommand }:

let
  inherit (config.environment.hidpi) scale;

  gtkCss = substituteAll {
    src = ../../data/config/gtk3/gtk.css;

    padding_left = toString (2 * scale);
  };

  settingsIni = substituteAll {
    src = ../../data/config/gtk3/settings.ini;
  };
in

runCommand "gtk-3.0" {} ''
  confd="$out/etc/xdg/gtk-3.0"
  install -D -m 444 "${gtkCss}" "$confd/gtk.css"
  install -D -m 444 "${settingsIni}" "$confd/settings.ini"
''
