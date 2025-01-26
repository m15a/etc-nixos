final: prev: {
  inherit (final.callPackage ./fish/lib.nix { })
    writeFishScript
    writeFishScriptBin
    writeFishApplication
    ;
  desptop-background = final.callPackage ./desptop-background/package.nix { };
  gitCustom = final.callPackage ./git/custom.nix { };
  lightdm-mini-greeter = final.callPackage ./lightdm-mini-greeter/package.nix {
    origin = prev.lightdm-mini-greeter;
  };
  maimCustom = final.callPackage ./maim/wrapper.nix { };
  oomox-gtk-theme = final.callPackage ./oomox-gtk-theme/package.nix { };
}
