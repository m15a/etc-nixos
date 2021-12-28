{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-misc.url = "github:mnacamura/nixpkgs-misc";
    nixpkgs-themix.url = "github:mnacamura/nixpkgs-themix";
    nixpkgs-mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-misc, nixpkgs-themix, nixpkgs-mozilla, ... }:
  let
    overlays-module = { config, lib, pkgs, ...}: {
      nixpkgs.overlays = [
        (import ./pkgs { inherit config lib; })
        nixpkgs-misc.overlay
        nixpkgs-themix.overlay
        (import "${nixpkgs-mozilla}/firefox-overlay.nix")
      ];
    };
  in {
    nixosConfigurations = {
      louise = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          overlays-module
          (import ./hosts/louise.nix)
        ];
      };
    };
  };
}
