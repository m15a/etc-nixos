{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environment;

  defaultColorTheme = {
    black     = "#000000";
    red       = "#800000";
    green     = "#008000";
    yellow    = "#808000";
    blue      = "#000080";
    magenta   = "#800080";
    cyan      = "#008080";
    white     = "#c0c0c0";
    brblack   = "#808080";
    brred     = "#ff0000";
    brgreen   = "#00ff00";
    bryellow  = "#ffff00";
    brblue    = "#0000ff";
    brmagenta = "#ff00ff";
    brcyan    = "#00ffff";
    brwhite   = "#ffffff";
  };

  isHexString = let
    hexChars = stringToCharacters "0123456789abcdef";
  in
  s: all (c: elem c hexChars) (stringToCharacters (toLower s));

  isHexColorCode = s:
  let
    prefix = substring 0 1 s;
    body = substring 1 7 s;
  in
  stringLength s == 7 && prefix == "#" && isHexString body; 
in

{
  options = {
    environment.colortheme = mkOption {
      type = with types; attrsOf str;
      default = defaultColorTheme;
      example = defaultColorTheme;
      description = ''
        Color theme to be used for various packages (console, vim, ...).  Each
        color is defined by a six-digit hexadecimal string with prefix '#'
        (e.g., "#1c1c1a"). It should include at least 16 colors: black, red,
        green, yellow, blue, magenta, cyan, white, brblack, brred, brgreen,
        bryellow, brblue, brmagenta, brcyan, and brwhite.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = let
          definedNames = attrNames cfg.colortheme;
          expectedNames = [
            "black"   "red"   "green"   "yellow"   "blue"   "magenta"   "cyan"   "white"
            "brblack" "brred" "brgreen" "bryellow" "brblue" "brmagenta" "brcyan" "brwhite"
          ];
        in all (n: elem n definedNames) expectedNames;
        message = ''
          At least 16 colors should be defined. See description of
          <option>environment.colortheme</option>.
        '';
      }

      {
        assertion = all isHexColorCode (attrValues cfg.colortheme);
        message = ''
          Invalid hexadicimal color code found.
        '';
      }
    ];

    console.colors = with cfg.colortheme;
    map (substring 1 8) [
        black   red   green   yellow   blue   magenta   cyan   white
      brblack brred brgreen bryellow brblue brmagenta brcyan brwhite
    ];
  };
}
