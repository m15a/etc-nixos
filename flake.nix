{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-misc = {
      url = "github:mnacamura/nixpkgs-misc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-themix = {
      url = "github:mnacamura/nixpkgs-themix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-misc, nixpkgs-themix, nixpkgs-mozilla, ... }:
  let
    nixpkgs-overlays = { config, lib, pkgs, ...}: {
      nixpkgs.overlays = [
        (import ./pkgs { inherit config lib; })
        nixpkgs-misc.overlay
        nixpkgs-themix.overlay
        (import "${nixpkgs-mozilla}/firefox-overlay.nix")
      ];
    };
    hosts = import ./hosts;
  in {
    nixosConfigurations = {
      louise = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs-overlays
          hosts.louise
        ];
      };
    };
  };
}
