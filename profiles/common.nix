{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/environment/colors
    ../modules/environment/hidpi.nix
  ];

  nix.package = pkgs.nixVersions.latest;
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.config.allowUnfree = true;
}
