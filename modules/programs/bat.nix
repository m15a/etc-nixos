{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.bat;
in

{
  options = {
    programs.bat = {
      enable = lib.mkEnableOption "bat";
      package = lib.mkPackageOption pkgs "bat" { };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    programs.fish.interactiveShellInit = ''
      function cat
          command bat $argv
      end
    '';
  };
}
