{
  config,
  lib,
  pkgs,
  ...
}:

let
  fcfg = config.programs.fish;
  cfg = config.programs.fish.plugins.pure;
in

{
  options = {
    programs.fish.plugins.pure = {
      enable = lib.mkEnableOption "Fish plugin <code>pure</code>";
      package = lib.mkPackageOption pkgs [ "fishPlugins" "pure" ] { };
    };
  };
  config = lib.mkIf (fcfg.enable && cfg.enable) {
    environment.systemPackages = [ cfg.package ];
    programs.fish.interactiveShellInit = ''
      set pure_enable_nixdevshell true
      set pure_symbol_nixdevshell_prefix "󱄅 "
      set pure_symbol_virtualenv_prefix " "
    '';
  };
}
