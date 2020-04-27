{ termite-unwrapped, configDir }:

termite-unwrapped.overrideAttrs (old: {
  name = old.name + "-wrapped";

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_CONFIG_DIRS : "${configDir}")
  '';
})
