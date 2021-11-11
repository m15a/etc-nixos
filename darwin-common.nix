{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/dummy.nix
    ./modules/colors
    ./modules/darwin/bash.nix
    ./modules/darwin/fish.nix
    ./modules/darwin/zsh.nix
  ];

  nix = {
    trustedUsers = [ "@admin" ];

    useSandbox = false;
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = let
      nixpkgs-misc = builtins.fetchTarball {
        url = "https://github.com/mnacamura/nixpkgs-misc/archive/main.tar.gz";
      };
    in
    [
      (import ./pkgs { inherit config; })
      (import nixpkgs-misc)
    ];
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

    systemPackages = with pkgs; [
      coreutils
      diffutils
      findutils
      gawk
      gnugrep
      gnused
      gnutar
      curl
      git
      less
      man
      patch
      which
      bzip2
      gzip
      xz
      configFiles.fish
    ];

    pathsToLink = [
      "/etc/fish/conf.d"
      "/etc/fish/functions"
    ];

    variables = {
      PAGER = "less -R";
      EDITOR = "vim";  # Available by default on macOS
      INFOPATH = makeProfileRelativePath [ "/info" "/share/info" ];
      MANPATH = makeProfileRelativePath [ "/man" "/share/man" ];
    };

    shells = with pkgs; [ fish ];

    shellAliases = {
      cp = "cp -i";
      mv = "mv -i";
      diff = "diff --color";
    };
  };

  programs = { # Shells
    bash.interactiveShellInit = ''
      ls() {
          if type -f lsd >/dev/null 2>&1; then
              command lsd "$@"
          else
              command ls -Fh --color --time-style=long-iso "$@"
          fi
      }

      alias l='ls'
      alias la='ls -a'
      alias ll='ls -l'
      alias lla='ls -la'
    '';

    fish.enable = true;
    fish.loginShellInit = ''
      if [ (id -u) -ge 501 ]  # normal user
          [ (id -un) = (id -gn) ]
          and umask 007
          or  umask 077
      else
          umask 022
      end
    '';
    fish.interactiveShellInit = ''
      function ls
          if type -fq lsd
              # iTerm2 does not print Nerd Font icons...somehow
              set -q ITERM_SESSION_ID
              and command lsd --icon never $argv
              or  command lsd $argv
          else
              command ls -Fh --color --time-style=long-iso $argv
          end
      end
      function cat
          type -fq bat
          and command bat $argv
          or  command cat $argv
      end

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
