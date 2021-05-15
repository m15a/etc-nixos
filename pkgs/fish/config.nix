{ config, lib, substituteAll, stdenv }:

let
  colors = lib.mapAttrs (_: s: lib.strings.substring 1 6 s) config.environment.colors.hex;

  colors_fish = substituteAll (colors // {
    src = ../../data/etc/fish/conf.d/colors.fish;
  });
in

stdenv.mkDerivation {
  name = "fish-etc";

  src = ../../data/etc/fish;

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
