{ config, lib, pkgs, ... }:

{
  # MacBook Pro (Late 2016, 13-inch)
  networking.hostName = "suzon";

  nix = {
    trustedUsers = [ "@admin" ];

    nixPath = [
      "darwin-config=$HOME/.config/nixos/${config.networking.hostName}.nix"
      "$HOME/.nix-defexpr/channels"
    ];

    useSandbox = false;

    buildCores = 4;
    maxJobs = 4;
  };

  environment = let
    makeProfileRelativePath = suffixes:
    with lib;
    concatStringsSep ":"
      (flip concatMap config.environment.profiles
        (profile: flip map suffixes
                    (suffix: "${profile}${suffix}")));
  in {
    systemPackages = with pkgs; let
      consolePkgs = [
        coreutils
        findutils
        gnumake
        gnugrep
        diffutils
        gawk
        gnused
        # strip
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
      PAGER = "less -R";
      EDITOR = "vim";  # Available by default on macOS
      INFOPATH = makeProfileRelativePath [ "/info" "/share/info" ];
      MANPATH = makeProfileRelativePath [ "/man" "/share/man" ];
    };

    shells = with pkgs; [ fish ];

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
      # Hack for issue https://github.com/LnL7/nix-darwin/issues/122
      for p in /run/current-system/sw/bin
        if not contains $p $fish_user_paths
          set -g fish_user_paths $p $fish_user_paths
        end
      end
    '';
    fish.interactiveShellInit = ''
      abbr --add la 'ls -a'
      abbr --add ll 'ls -l'
      abbr --add lla 'ls -la'
    '';
  } // { # Others
  };

  services = {
    nix-daemon.enable = false;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;
}
