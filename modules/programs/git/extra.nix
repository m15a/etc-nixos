{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.git;
in

{
  config = lib.mkIf cfg.enable {
    programs.fish.interactiveShellInit = ''
      abbr --add g   -- git
      abbr --add ga  -- git add
      abbr --add gb  -- git branch
      abbr --add gc  -- git commit
      abbr --add gcl -- git clone
      abbr --add gco -- git checkout
      abbr --add gcp -- git cherry-pick
      abbr --add gd  -- git diff --word-diff=color
      abbr --add gdc -- git diff --cached --word-diff=color
      abbr --add gD  -- git diff
      abbr --add gDc -- git diff --cached
      abbr --add gDC -- git diff --cached
      abbr --add gl  -- git log
      abbr --add glf -- git ls-files
      abbr --add glg -- git log --graph --oneline
      abbr --add glo -- git log --oneline
      abbr --add gls -- git log --stat
      abbr --add gp  -- git pull
      abbr --add gs  -- git show --word-diff=color
      abbr --add gS  -- git show
      abbr --add gw  -- git status
    '';
  };
}
