{ config, lib, pkgs, ... }:

{
  nix = {
    trustedUsers = [ "@admin" ];

    useSandbox = false;
  };

  environment = let
    makeProfileRelativePath = suffixes:
    with lib;
    concatStringsSep ":"
      (flip concatMap config.environment.profiles
        (profile: flip map suffixes
                    (suffix: "${profile}${suffix}")));
  in {
    darwinConfig = "$HOME/.config/nixos/${config.networking.hostName}.nix";

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
      diff = "diff --color";
    };
  };

  programs = { # Shells
    bash.interactiveShellInit = ''
      alias l='ls'
      alias la='ls -a'
      alias ll='ls -l'
      alias lla='ls -la'
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
      abbr --add l 'ls'
      abbr --add la 'ls -a'
      abbr --add ll 'ls -l'
      abbr --add lla 'ls -la'
      abbr --add h history
      abbr --add d  dirh
      abbr --add nd nextd
      abbr --add pd prevd
    '';
  } // { # Others
  };

  services = {
    nix-daemon.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
