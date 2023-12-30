{ config, lib, substituteAll, stdenv }:

let
  hex_colors = lib.mapAttrs (_: s: lib.strings.substring 1 6 s)
  config.environment.colors.hex;

  nr_colors = with config.environment.colors.nr; {
    accent_nr = accent;
    sel_fg_nr = sel_fg;
  };

  colors_fish = substituteAll (hex_colors // nr_colors // {
    src = ./conf.d/colors.fish;
  });
in

stdenv.mkDerivation {
  name = "fish-etc";

  src = ./.;

  buildCommand = ''
    for file in $src/conf.d/*; do
        install -m444 "$file" -Dt $out/etc/fish/conf.d
    done
    for file in $src/functions/*; do
        install -m444 "$file" -Dt $out/etc/fish/functions
    done
    rm -f $out/etc/fish/conf.d/colors.fish
    ln -s ${colors_fish} $out/etc/fish/conf.d/colors.fish
  '';
}
