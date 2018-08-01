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
    systemPackages = with pkgs; let
      consolePkgs = [
        coreutils
        findutils
        gnumake
        gnugrep
        diffutils
        gawk
        gnused
        strip
        patch
        gnutar
        bzip2
        gzip
        xz
      ];
      miscPkgs = [
      ];
    in consolePkgs ++ miscPkgs;
    variables = {
      EDITOR = "vim";  # Available by default on macOS
    };
    shells = with pkgs; [
      fish
    ];
    shellAliases = {
      ls = "ls -Fh --color --time-style=long-iso";
      cp = "cp -i";
      mv = "mv -i";
    };
  };

  programs = { # Shells
    bash.interactiveShellInit = ''
      alias la="ls -a"
      alias ll="ls -l"
      alias lla="ls -la"
    '';
    fish.enable = true;
    fish.shellInit = ''
      umask 077
    '';
    fish.interactiveShellInit = ''
      abbr --add la 'ls -a'
      abbr --add ll 'ls -l'
      abbr --add lla 'ls -la'
    '';
  } // { # Others
  };

  services = {
    nix-daemon.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;
}
