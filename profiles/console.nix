{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/programs/bat.nix
    ../modules/programs/fish/extra.nix
    ../modules/programs/fish/plugins/pure.nix
    ../modules/programs/git/extra.nix
    ../modules/programs/lsd.nix
    ../modules/programs/ripgrep.nix
  ];

  environment.shellAliases = {
    cp = "cp -i";
    mv = "mv -i";
    diff = "diff --color=auto";
  };
  environment.systemPackages = with pkgs; [
    fd
    glow
    htop
    trash-cli
  ];

  programs = {
    bat.enable = true;
    direnv.enable = true;
    fish.enable = true;
    fish.plugins.pure.enable = true;
    git.enable = true;
    git.package = pkgs.gitCustom;
    git.config = {
      init.defaultBranch = "main";
      push.default = "current";
      status.short = true;
    };
    lsd.enable = true;
    ripgrep.enable = true;
  };
}
