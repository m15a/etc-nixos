{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-repl
  ];
  environment.variables.EDITOR = "vim";  # Available by default on macOS

  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  services.nix-daemon.enable = true;

  nix.trustedUsers = [ "@admin" ];
  # nix.useSandbox = true;  # still does not work for most cases
  nix.package = pkgs.nixUnstable;
  nix.maxJobs = 4;
  nix.buildCores = 4;
  nix.nixPath = [
    "darwin-config=$HOME/Repos/nix-configurations/suzon-configuration.nix"
    "/Users/mnacamura/.nix-defexpr/channels"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 2;
}
