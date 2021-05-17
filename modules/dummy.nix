{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    console = {
      colors = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Dummy option for macOS.
        '';
      };
    };
  };

  config = {
  };
}
