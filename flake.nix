{
  description = "My NoxOS systems flake, rebooted";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      flake-utils,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      bless =
        system: _: host-module:
        system {
          modules = [
            (_: {
              system.configurationRevision = self.rev or self.dirtyRev or null;
              nixpkgs.overlays = [ self.overlays.default ];
            })
            host-module
          ];
        };
      hosts = import ./hosts { inherit nixos-hardware; };
    in
    {
      nixosConfigurations = builtins.mapAttrs (bless nixosSystem) {
        inherit (hosts) louise;
      };
      overlays.default = import ./pkgs/overlay.nix;
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        packages = import ./pkgs { inherit pkgs; };
        treefmt = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        inherit packages;
        formatter = treefmt.config.build.wrapper;
        checks = packages // {
          format = treefmt.config.build.check self;
        };
        devShells.default = treefmt.config.build.devShell;
      }
    ));
}
