{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environment.colortheme;

  defaultPalette = {
    black     = { nr =  0; hex = "#000000"; };
    red       = { nr =  1; hex = "#800000"; };
    green     = { nr =  2; hex = "#008000"; };
    yellow    = { nr =  3; hex = "#808000"; };
    blue      = { nr =  4; hex = "#000080"; };
    magenta   = { nr =  5; hex = "#800080"; };
    cyan      = { nr =  6; hex = "#008080"; };
    white     = { nr =  7; hex = "#c0c0c0"; };
    brblack   = { nr =  8; hex = "#808080"; };
    brred     = { nr =  9; hex = "#ff0000"; };
    brgreen   = { nr = 10; hex = "#00ff00"; };
    bryellow  = { nr = 11; hex = "#ffff00"; };
    brblue    = { nr = 12; hex = "#0000ff"; };
    brmagenta = { nr = 13; hex = "#ff00ff"; };
    brcyan    = { nr = 14; hex = "#00ffff"; };
    brwhite   = { nr = 15; hex = "#ffffff"; };
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
    environment.colortheme.palette = mkOption {
      type = with types; attrsOf attrs;
      default = defaultPalette;
      example = defaultPalette;
      description = ''
        Color theme to be used for various packages (console, vim, ...). Each
        color is defined by an attrset which may have <code>nr</code> key and
        must have <code>hex</code> key: <code>nr</code> key is a xterm color
        number (e.g., black is 0), and <code>hex</code> key is a six-digit
        hexadecimal string with prefix '#' (e.g., "#1c1c1a"). It should
        include at least 16 colors: black, red, green, yellow, blue, magenta,
        cyan, white, brblack, brred, brgreen, bryellow, brblue, brmagenta,
        brcyan, and brwhite.
      '';
    };

    environment.colortheme.nr = mkOption {
      type = with types; attrsOf int;
      description = ''
        <code>nr</code> values of <option>environment.colortheme.palette</option>.
      '';
    };

    environment.colortheme.hex = mkOption {
      type = with types; attrsOf str;
      description = ''
        <code>hex</code> values of <option>environment.colortheme.palette</option>.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = let
          definedNames = attrNames cfg.palette;
          expectedNames = [
            "black"   "red"   "green"   "yellow"   "blue"   "magenta"   "cyan"   "white"
            "brblack" "brred" "brgreen" "bryellow" "brblue" "brmagenta" "brcyan" "brwhite"
          ];
        in all (n: elem n definedNames) expectedNames;
        message = ''
          At least 16 colors should be defined. See description of
          <option>environment.colortheme.palette</option>.
        '';
      }

      {
        assertion = all (b: b) (mapAttrsToList (_: c: c ? hex) cfg.palette);
        message = ''
          Color(s) with no hex value found. See description of
          <option>environment.colortheme.palette</option>.
        '';
      }

      {
        assertion = all isInt (attrValues cfg.nr);
        message = ''
          Invalid xterm color number found. See description of
          <option>environment.colortheme.palette</option>.
        '';
      }

      {
        assertion = all isHexColorCode (attrValues cfg.hex);
        message = ''
          Invalid hexadicimal color code found. See description of
          <option>environment.colortheme.palette</option>.
        '';
      }
    ];

    environment.colortheme.nr = mapAttrs (_: c: c.nr) cfg.palette;

    environment.colortheme.hex = mapAttrs (_: c: c.hex) cfg.palette;

    console.colors = with cfg.hex;
    map (substring 1 8) [
        black   red   green   yellow   blue   magenta   cyan   white
      brblack brred brgreen bryellow brblue brmagenta brcyan brwhite
    ];
  };
}
