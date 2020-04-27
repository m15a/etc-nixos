{ termite-unwrapped, configDir }:

termite-unwrapped.overrideAttrs (old: {
  name = with old; "${pname}-${version}-wrapped";

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_CONFIG_DIRS : "${configDir}")
  '';
})
