{ rofi, buildEnv, makeWrapper, configFile }:


buildEnv {
  name = "${rofi.name}-wrapped";

  paths = [ rofi ];
  pathsToLink = [ "/share" ];

  buildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir "$out/bin"
    makeWrapper "${rofi}/bin/rofi" "$out/bin/rofi" \
        --add-flags "-config '${configFile}'"
    for path in "${rofi}/bin/"*; do
        name="$(basename "$path")"
        if [ "$name" != rofi ]; then
            ln -s "$path" "$out/bin/$name"
        fi
    done
  '';
}
