{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.alacritty;
  inherit (config.environment.colors) theme;
  inherit (config.nixpkgs) hostPlatform;
in

{
  config = lib.mkIf cfg.enable {
    programs.alacritty.config = lib.mkMerge [
      {
        general.live_config_reload = false;
        window.dimensions = {
          columns = 100;
          lines = 44;
        };
        font = {
          size = 16;
          offset.x = 1;
          offset.y = 1;
        };
        colors = with (lib.mapAttrs (_: c: c.hex) theme); {
          primary = {
            foreground = term_fg;
            background = term_bg;
          };
          cursor = {
            text = "CellBackground";
            cursor = bright_orange;
          };
          vi_mode_cursor = {
            text = "CellBackground";
            cursor = bright_magenta;
          };
          search.matches = {
            foreground = "CellBackground";
            background = "CellForeground";
          };
          search.focused_match = {
            foreground = "CellBackground";
            background = bright_magenta;
          };
          hints.start = {
            foreground = "CellBackground";
            background = bright_magenta;
          };
          hints.end = {
            foreground = "CellBackground";
            background = "CellForeground";
          };
          line_indicator = {
            foreground = term_bg;
            background = term_fg;
          };
          footer_bar = {
            foreground = term_bg;
            background = term_fg;
          };
          normal = {
            inherit
              black
              red
              green
              yellow
              blue
              magenta
              cyan
              white
              ;
          };
          bright = {
            black = bright_black;
            red = bright_red;
            green = bright_green;
            yellow = bright_yellow;
            blue = bright_blue;
            magenta = bright_magenta;
            cyan = bright_cyan;
            white = bright_white;
          };
        };
        cursor.style.blinking = "On";
        mouse.hide_when_typing = true;
        keyboard.bindings = [
          # Alternative binding on macOS
          # https://github.com/alacritty/alacritty/issues/8223
          {
            key = "Escape";
            mods = "Control";
            mode = "~Search";
            action = "ToggleViMode";
          }
        ];
      }
      (lib.mkIf hostPlatform.isDarwin {
        window.decorations = "Buttonless";
      })
      (lib.mkIf (!hostPlatform.isDarwin && config.environment.hidpi.enable) {
        env.WINIT_X11_SCALE_FACTOR = config.environment.hidpi.scale;
      })
      (lib.mkIf config.programs.fish.enable {
        terminal.shell = {
          program = lib.getExe config.programs.fish.package;
          args = [ "--login" ];
        };
      })
    ];
  };
}
