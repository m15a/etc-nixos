{ config, substituteAll, runCommand }:

let
  inherit (config.environment.hidpi) scale;

  gtkCss = substituteAll {
    src = ../../data/etc/xdg/gtk-3.0/gtk.css;

    termite_padding = toString 8;  # seems being scaled by GDK_SCALE
  };

  settingsIni = substituteAll {
    src = ../../data/etc/xdg/gtk-3.0/settings.ini;
  };
in

runCommand "gtk-3.0" {} ''
  confd="$out/etc/xdg/gtk-3.0"
  install -D -m 444 "${gtkCss}" "$confd/gtk.css"
  install -D -m 444 "${settingsIni}" "$confd/settings.ini"
''
