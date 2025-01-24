{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/programs/alacritty
    ../modules/programs/alacritty/config.nix
    ../modules/programs/feh
    ../modules/programs/feh/config.nix
  ];

  programs.alacritty.enable = true;
}
