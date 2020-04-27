{ zathura, runCommand, buildEnv, makeWrapper, configFile }:

let
  configDir = runCommand "zathura-config-dir" {} ''
    install -D -m 444 "${configFile}" "$out/zathurarc"
  '';
in

buildEnv {
  name = "${zathura.name}-wrapped";

  paths = [ zathura ];
  pathsToLink = [ "/share" ];

  buildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir "$out/bin"
    makeWrapper "${zathura}/bin/zathura" "$out/bin/zathura" \
        --add-flags "--config-dir '${configDir}'"
  '';
}
