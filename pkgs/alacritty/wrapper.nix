{ alacritty, buildEnv, makeWrapper, configFile }:

buildEnv {
  name = "${alacritty.name}-wrapped";

  paths = [ alacritty ];
  pathsToLink = [ "/share" "/nix-support" ];

  buildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir "$out/bin"
    makeWrapper "${alacritty}/bin/alacritty" "$out/bin/alacritty" \
        --add-flags "--config-file '${configFile}'"
    for path in "${alacritty}/bin/"*; do
        name="$(basename "$path")"
        if [ "$name" != alacritty ]; then
            ln -s "$path" "$out/bin/$name"
        fi
    done
  '';
}
