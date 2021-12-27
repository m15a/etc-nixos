{ config, lib, ... }:

final: prev:

with prev.lib;

let
  nixpkgs-misc = builtins.getFlake "github:mnacamura/nixpkgs-misc";
  nixpkgs-themix = builtins.getFlake "github:mnacamura/nixpkgs-themix";
  nixpkgs-mozilla = builtins.fetchTarball {
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz";
  };
in

composeManyExtensions [
  (import ./pkgs { inherit config lib; })
  nixpkgs-misc.overlay
  nixpkgs-themix.overlay
  (import "${nixpkgs-mozilla}/firefox-overlay.nix")
] final prev
