final: prev: {
  inherit (final.callPackage ./fish/lib.nix {})
  writeFishScript
  writeFishScriptBin
  writeFishApplication
  ;
  desptop-background = final.callPackage ./desptop-background/package.nix { };
  gitCustom = final.callPackage ./git/custom.nix { };
  maimCustom = final.callPackage ./maim/wrapper.nix {};
  oomox-gtk-theme = final.callPackage ./oomox-gtk-theme/package.nix { };
}
