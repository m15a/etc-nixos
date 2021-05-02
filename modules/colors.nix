{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environment.colors;

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
in

{
  options = {
    environment.colors.palette = mkOption {
      type = with types; attrsOf attrs;
      default = defaultPalette;
      example = defaultPalette;
      description = ''
        Color theme to be used for various packages (console, vim, ...). Each
        color is defined by an attrset which may have <code>nr</code> and must
        have <code>hex</code> attrs: <code>nr</code> is a xterm color number
        (e.g., black is 0), and <code>hex</code> is a hex color code with
        prefix '#' (e.g., "#1c1c1a"). It should include at least 16 colors:
        <code>black</code>, <code>red</code>, <code>green</code>,
        <code>yellow</code>, <code>blue</code>, <code>magenta</code>,
        <code>cyan</code>, <code>white</code>, <code>brblack</code>,
        <code>brred</code>, <code>brgreen</code>, <code>bryellow</code>,
        <code>brblue</code>, <code>brmagenta</code>, <code>brcyan</code>, and
        <code>brwhite</code>.
      '';
    };

    environment.colors.nr = mkOption {
      type = with types; attrsOf (ints.between 0 255);
      description = ''
        <code>nr</code> values of <option>environment.colors.palette</option>.
      '';
    };

    environment.colors.hex = mkOption {
      type = with types; attrsOf (strMatching "^#[0-9abcdefABCDEF]{6}$");
      description = ''
        <code>hex</code> values of <option>environment.colors.palette</option>.
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
          <option>environment.colors.palette</option>.
        '';
      }

      {
        assertion = all (b: b) (mapAttrsToList (_: c: c ? hex) cfg.palette);
        message = ''
          Color(s) with no hex value found. See description of
          <option>environment.colors.palette</option>.
        '';
      }
    ];

    environment.colors.nr = mapAttrs (_: c: c.nr) (filterAttrs (_: c: c ?  nr) cfg.palette);

    environment.colors.hex = mapAttrs (_: c: c.hex) cfg.palette;

    console.colors = with cfg.hex;
    map (substring 1 8) [
        black   red   green   yellow   blue   magenta   cyan   white
      brblack brred brgreen bryellow brblue brmagenta brcyan brwhite
    ];
  };
}
