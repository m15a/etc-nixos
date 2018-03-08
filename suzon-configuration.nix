{ config, pkgs, ... }:

{
  # Nix options
  nix.trustedUsers = [ "@admin" ];
  # nix.useSandbox = true;
  nix.maxJobs = 4;
  nix.buildCores = 4;
  nix.nixPath = [
    "darwin-config=$HOME/Repos/nix-configurations/suzon-configuration.nix"
    "/Users/mnacamura/.nix-defexpr/channels"
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];
  programs.fish.enable = true;

  environment.variables = {
    EDITOR = "vim";  # Available by default on macOS
  };

  environment.shells = with pkgs; [
    fish
  ];

  # List services that you want to enable:

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 2;
}
