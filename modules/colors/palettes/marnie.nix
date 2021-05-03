# Marnie theme

rec {
  bg = xgray3;
  fg = white;
  menu_fg = term_fg;
  menu_bg = term_bg;
  hdr_fg = term_fg;
  hdr_bg = term_bg;
  sel_bg = brmagenta;
  sel_fg = term_bg;
  accent = cyan;
  txt_bg = term_bg;
  txt_fg = term_fg;
  btn_bg = accent;
  btn_fg = term_bg;
  hdr_btn_bg = accent;
  hdr_btn_fg = term_bg;
  wm_border_focus = sel_bg;
  wm_border_unfocus = brblack;
  caret1_fg = sel_bg;
  caret2_fg = sel_bg;

  icons_light = brmagenta;
  icons_medium = magenta;
  icons_dark = red;
  icons_sym_action = fg;
  icons_sym_panel = fg;

  term_fg = white;
  term_bg = black;

  black     = { nr =   0; hex = "#2b2a29"; };
  red       = { nr =   1; hex = "#a61c39"; };
  green     = { nr =   2; hex = "#338475"; };
  yellow    = { nr =   3; hex = "#e5835e"; };
  blue      = { nr =   4; hex = "#187984"; };
  magenta   = { nr =   5; hex = "#da6f75"; };
  cyan      = { nr =   6; hex = "#33c8be"; };
  white     = { nr =   7; hex = "#fff8e6"; };

  brblack   = { nr =   8; hex = "#aaa9a7"; };
  brred     = { nr =   9; hex = "#ca3c46"; };
  brgreen   = { nr =  10; hex = "#20998c"; };
  bryellow  = { nr =  11; hex = "#edd079"; };
  brblue    = { nr =  12; hex = "#9bb2c2"; };
  brmagenta = { nr =  13; hex = "#fea7ac"; };
  brcyan    = { nr =  14; hex = "#a8f8e5"; };
  brwhite   = { nr =  15; hex = "#fff9f2"; };

  # Borrowd from Srcery
  hardblack = { nr = 233; hex = "#121212"; };
  xgray1    = { nr = 235; hex = "#262626"; };
  xgray2    = { nr = 236; hex = "#303030"; };
  xgray3    = { nr = 237; hex = "#3a3a3a"; };
  xgray4    = { nr = 238; hex = "#444444"; };
  xgray5    = { nr = 239; hex = "#4e4e4e"; };
  xgray6    = { nr = 240; hex = "#585858"; };
}
