{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-misc = {
      url = "github:mnacamura/nixpkgs-misc";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs-themix = {
      url = "github:mnacamura/nixpkgs-themix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-misc, nixpkgs-themix, nix-darwin, ... }:
  let
    nixpkgs-overlays = { config, lib, pkgs, ...}: {
      nixpkgs.overlays = [
        (import ./pkgs { inherit config lib; })
        nixpkgs-misc.overlay
        nixpkgs-themix.overlay
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

    darwinConfigurations = {
      Y-0371 = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          nixpkgs-overlays
          hosts.Y-0371
        ];
      };
    };
  };
}
