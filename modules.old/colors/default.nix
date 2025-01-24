{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.environment.colors;

  color256 = with types; ints.between 0 255;

  colorHex = with types; strMatching "^#[0-9abcdefABCDEF]{6}$";

  palettes = {
    default = import ./palettes/default.nix;
    srcery = import ./palettes/srcery.nix;
  };
in

{
  options = {
    environment.colors.palette = mkOption {
      type =
        with types;
        attrsOf (
          attrsOf (oneOf [
            color256
            colorHex
          ])
        );
      inherit (palettes) default;
      example = palettes.srcery;
      description = ''
        Color theme to be used for various packages (console, vim, ...). Each
        color is defined by an attrset which have <code>nr</code> and
        <code>hex</code> attrs: <code>nr</code> is an xterm color number
        (e.g., black is 0), and <code>hex</code> is a hex color code with
        prefix '#' (e.g., "#1c1c1a"). It should include colors for terminal use,
        <code>term_fg</code>, <code>term_bg</code>, <code>black</code>,
        <code>red</code>, <code>green</code>, <code>yellow</code>,
        <code>blue</code>, <code>magenta</code>, <code>cyan</code>,
        <code>white</code>, <code>brblack</code>, <code>brred</code>,
        <code>brgreen</code>, <code>bryellow</code>, <code>brblue</code>,
        <code>brmagenta</code>, <code>brcyan</code>, <code>brwhite</code>,
        and colors for GUI use, <code>bg</code>, <code>fg</code>,
        <code>menu_fg</code>, <code>menu_bg</code>, <code>hdr_fg</code>,
        <code>hdr_bg</code>, <code>sel_bg</code>, <code>sel_fg</code>,
        <code>accent</code>, <code>txt_bg</code>, <code>txt_fg</code>,
        <code>btn_bg</code>, <code>btn_fg</code>, <code>hdr_btn_bg</code>,
        <code>hdr_btn_fg</code>, <code>wm_border_focus</code>,
        <code>wm_border_unfocus</code>, <code>caret1_fg</code>,
        <code>caret2_fg</code>, <code>icons_light</code>,
        <code>icons_medium</code>, <code>icons_dark</code>,
        <code>icons_sym_action</code>, and <code>icons_sym_panel</code>.
        For more information about these colors, try to use the Themix GUI
        designer.
      '';
    };

    environment.colors.palettes = mkOption {
      type = with types; attrsOf (attrsOf attrs);
      default = palettes;
      description = ''
        A collection of color themes. For more information, see
        <code>environment.colors.palette</code>.
      '';
    };

    environment.colors.nr = mkOption {
      type = with types; attrsOf color256;
      description = ''
        <code>nr</code> values of <option>environment.colors.palette</option>.
      '';
    };

    environment.colors.hex = mkOption {
      type = with types; attrsOf colorHex;
      description = ''
        <code>hex</code> values of <option>environment.colors.palette</option>.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion =
          let
            definedNames = attrNames cfg.palette;
            expectedNames = [
              "black"
              "red"
              "green"
              "yellow"
              "blue"
              "magenta"
              "cyan"
              "white"
              "brblack"
              "brred"
              "brgreen"
              "bryellow"
              "brblue"
              "brmagenta"
              "brcyan"
              "brwhite"
            ];
          in
          all (n: elem n definedNames) expectedNames;
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

    environment.colors.nr = mapAttrs (_: c: c.nr) (
      filterAttrs (_: c: c ? nr) cfg.palette
    );

    environment.colors.hex = mapAttrs (_: c: c.hex) cfg.palette;

    console.colors =
      with cfg.hex;
      map (substring 1 8) [
        black
        red
        green
        yellow
        blue
        magenta
        cyan
        white
        brblack
        brred
        brgreen
        bryellow
        brblue
        brmagenta
        brcyan
        brwhite
      ];
  };
}
