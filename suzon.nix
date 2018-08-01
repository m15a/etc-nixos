{ config, pkgs, ... }:

{
  networking.hostName = "suzon";

  nix = {
    package = pkgs.nix;
    trustedUsers = [ "@admin" ];
    # useSandbox = true;
    nixPath = [
      "darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix"
      "$HOME/.nix-defexpr/channels"
    ];
    buildCores = 4;
    maxJobs = 4;
  };

  environment = {
    systemPackages = with pkgs; [
      bzip2
      coreutils
      diffutils
      findutils
      gawk
      gnugrep
      gnused
      gnutar
      gzip
      patch
      xz
    ];
    variables = {
      EDITOR = "vim";  # Available by default on macOS
    };
    shells = with pkgs; [
      fish
    ];
  };

  programs = {
    fish.enable = true;
  };

  services = {
    nix-daemon.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;
}
