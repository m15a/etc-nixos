{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.ripgrep;
in

{
  options = {
    programs.ripgrep = {
      enable = lib.mkEnableOption "ripgrep";
      package = lib.mkPackageOption pkgs "ripgrep" { };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    programs.fish.interactiveShellInit = ''
      abbr --add r -- rg -S
    '';
  };
}
