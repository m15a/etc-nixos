{ config, lib, feh, buildEnv, makeWrapper }:

let
  inherit (config.environment) colors;
in

buildEnv {
  name = "${feh.name}-wrapped";

  paths = [ feh.man ];

  buildInputs = [ makeWrapper ];

  postBuild = with colors.hex; ''
    mkdir "$out/bin"
    makeWrapper "${feh.out}/bin/feh" "$out/bin/feh" \
        --add-flags "--image-bg '${black}'"
  '';
}
