# srcery-palette@1.0.4
# https://github.com/srcery-colors/srcery-palette

rec {
  black     = { nr =  0; hex = "#1C1B19"; };
  red       = { nr =  1; hex = "#EF2F27"; };
  green     = { nr =  2; hex = "#519F50"; };
  yellow    = { nr =  3; hex = "#FBB829"; };
  blue      = { nr =  4; hex = "#2C78BF"; };
  magenta   = { nr =  5; hex = "#E02C6D"; };
  cyan      = { nr =  6; hex = "#0AAEB3"; };
  white     = { nr =  7; hex = "#BAA67F"; };
  brblack   = { nr =  8; hex = "#918175"; };
  brred     = { nr =  9; hex = "#F75341"; };
  brgreen   = { nr = 10; hex = "#98BC37"; };
  bryellow  = { nr = 11; hex = "#FED06E"; };
  brblue    = { nr = 12; hex = "#68A8E4"; };
  brmagenta = { nr = 13; hex = "#FF5C8F"; };
  brcyan    = { nr = 14; hex = "#2BE4D0"; };
  brwhite   = { nr = 15; hex = "#FCE8C3"; };

  orange    = { nr = 202; hex = "#FF5F00"; };
  brorange  = { nr = 208; hex = "#FF8700"; };
  hardblack = { nr = 233; hex = "#121212"; };
  teal      = { nr =  30; hex = "#008080"; };
  xgray1    = { nr = 235; hex = "#262626"; };
  xgray2    = { nr = 236; hex = "#303030"; };
  xgray3    = { nr = 237; hex = "#3A3A3A"; };
  xgray4    = { nr = 238; hex = "#444444"; };
  xgray5    = { nr = 239; hex = "#4E4E4E"; };
  xgray6    = { nr = 240; hex = "#585858"; };
  xgray7    = { nr = 241; hex = "#626262"; };
  xgray8    = { nr = 242; hex = "#6C6C6C"; };
  xgray9    = { nr = 243; hex = "#767676"; };
  xgray10   = { nr = 244; hex = "#808080"; };
  xgray11   = { nr = 245; hex = "#8A8A8A"; };
  xgray12   = { nr = 246; hex = "#949494"; };

  bg = xgray1;
  fg = brwhite;
  menu_fg = term_fg;
  menu_bg = term_bg;
  hdr_fg = term_fg;
  hdr_bg = term_bg;
  sel_bg = orange;
  sel_fg = term_fg;
  accent = teal;
  txt_bg = term_bg;
  txt_fg = term_fg;
  btn_bg = term_bg;
  btn_fg = term_fg;
  hdr_btn_bg = term_bg;
  hdr_btn_fg = term_fg;
  wm_border_focus = sel_bg;
  wm_border_unfocus = brblack;
  caret1_fg = sel_bg;
  caret2_fg = sel_bg;

  icons_light = brred;
  icons_medium = red;
  icons_dark = red;
  icons_sym_action = fg;
  icons_sym_panel = fg;

  term_fg = brwhite;
  term_bg = black;
}
