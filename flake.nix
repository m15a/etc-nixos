{
  inputs = {
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
    nixpkgs-mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };

    flake-utils.url = "github:numtide/flake-utils";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-misc, nixpkgs-themix, nixpkgs-mozilla, darwin, ... }:
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
      Y-0371 = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          nixpkgs-overlays
          hosts.Y-0371
        ];
      };
    };
  };
}
