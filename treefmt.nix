{ pkgs, ... }:
{
  programs.nixfmt.enable = true;
  programs.statix.enable = true;
  programs.statix.disabled-lints = [
    "repeated_keys"
  ];
  programs.deadnix.enable = true;
  programs.deadnix.no-lambda-arg = true;
  programs.deadnix.no-lambda-pattern-names = true;
  settings.global.excludes = [
    "**/.gitignore"
    "*.md"
    "LICENSE"
  ];
  settings.formatter.nixfmt.options = [ "--width=80" ];
}
