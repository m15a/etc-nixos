{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.lsd;
in

{
  options = {
    programs.lsd = {
      enable = lib.mkEnableOption "lsd";
      package = lib.mkPackageOption pkgs "lsd" { };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    programs.fish.interactiveShellInit = ''
      function ls
          command lsd --date=+"%Y-%m-%d %H:%M" $argv
      end
      function tree
          command lsd --date=+"%Y-%m-%d %H:%M" --tree $argv
      end
      abbr --add t tree
    '';
  };
}
