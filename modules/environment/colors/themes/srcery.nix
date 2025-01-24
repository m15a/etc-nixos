{ srcery }:

with srcery;

rec {
  term_fg = bright_white;
  term_bg = black;
  sel_fg = term_bg;
  sel_bg = bright_orange;
  accent = bright_magenta;
  error = bright_red;
  warning = bright_yellow;
  inherit (primary)
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
    bright_black
    bright_red
    bright_green
    bright_yellow
    bright_blue
    bright_magenta
    bright_cyan
    bright_white
    ;
  inherit (secondary)
    orange
    bright_orange
    hard_black
    teal
    xgray1
    xgray2
    xgray3
    xgray4
    xgray5
    xgray6
    xgray7
    xgray8
    xgray9
    xgray10
    xgray11
    xgray12
    ;
}
