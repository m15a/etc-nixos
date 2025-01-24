{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.environment.colors;

  types = with lib.types; rec {
    color256 = ints.between 0 255;
    colorHex = strMatching "^#[0-9abcdefABCDEF]{6}$";
    color = attrsOf (oneOf [
      color256
      colorHex
    ]);
    palette = attrsOf (oneOf [
      palette
      color
    ]);
    theme = attrsOf color;
  };

  palettes = import ./palettes;
  themes = import ./themes { inherit palettes; };
in

{
  options = {
    environment.colors = {
      palettes = lib.mkOption {
        type = lib.types.attrsOf types.palette;
        default = palettes;
        description = ''
          A collection of color palettes.
        '';
      };
      themes = lib.mkOption {
        type = lib.types.attrsOf types.theme;
        default = themes;
        description = ''
          A collection of color themes.
        '';
      };
      theme = lib.mkOption {
        type = types.theme;
        default = cfg.themes.srcery;
        description = ''
          Main color theme for various applications (console, vim, ...).
          Each color should be defined by an attrset having <code>index</code>
          and <code>hex</code> attrs: <code>index</code> is an xterm color
          number (e.g., black is 0), and <code>hex</code> is a hex color code
          (e.g., "1c1c1a").

          It must contain color attrs for terminal use, i.e.,
          <code>term_fg</code>,
          <code>term_bg</code>,
          <code>black</code>,
          <code>red</code>,
          <code>green</code>,
          <code>yellow</code>,
          <code>blue</code>,
          <code>magenta</code>,
          <code>cyan</code>,
          <code>white</code>,
          <code>bright_black</code>,
          <code>bright_red</code>,
          <code>bright_green</code>,
          <code>bright_yellow</code>,
          <code>bright_blue</code>,
          <code>bright_magenta</code>,
          <code>bright_cyan</code>, and
          <code>bright_white</code>.
        '';
      };
    };
  };

  config = {
    assertions = [
      {
        assertion =
          let
            definedNames = lib.attrNames cfg.theme;
            expectedNames = [
              "term_fg"
              "term_bg"
              "black"
              "red"
              "green"
              "yellow"
              "blue"
              "magenta"
              "cyan"
              "white"
              "bright_black"
              "bright_red"
              "bright_green"
              "bright_yellow"
              "bright_blue"
              "bright_magenta"
              "bright_cyan"
              "bright_white"
            ];
          in
          lib.all (n: lib.elem n definedNames) expectedNames;
        message = ''
          Undefined color(s) found in <option>environment.colors.theme</option>.
        '';
      }
      {
        assertion = lib.all (b: b) (lib.mapAttrsToList (_: c: c ? hex) cfg.theme);
        message = ''
          Color(s) with no hex value found in <option>environment.colors.palette</option>.
        '';
      }
    ];
  };
}
