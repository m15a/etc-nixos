{ config, lib, feh, buildEnv, makeWrapper }:

let
  colortheme = lib.mapAttrs (_: c: c.hex) config.environment.colortheme.palette;
in

buildEnv {
  name = "${feh.name}-wrapped";

  paths = [ feh.man ];

  buildInputs = [ makeWrapper ];

  postBuild = with colortheme; ''
    mkdir "$out/bin"
    makeWrapper "${feh.out}/bin/feh" "$out/bin/feh" \
        --add-flags "--image-bg '${black}'"
  '';
}
