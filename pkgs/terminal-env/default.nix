{ buildEnv, pkgs }:

buildEnv {
  name = "terminal-env";
  paths = with pkgs; [
    bat
    fd
    file
    htop
    lf
    lsd
    ripgrep
    skim
    trash-cli
    tree
  ];
}
