{ adapta-gtk-theme, lib
, selectionColor ? "#00BCD4"
, accentColor ? "#4DB6AC"
, suggestionColor ? "#009688"
, destructionColor ? "#FF5252"
, enableParallel ? false
, enableGnome ? false
, enableCinnamon ? false
, enableFlashback ? false
, enableXfce ? false
, enableMate ? false
, enableOpenbox ? false
, enableGtkNext ? false
, enablePlank ? false
, enableTelegram ? false
, enableTweetdeck ? false
}:

adapta-gtk-theme.overrideAttrs (old: {
  pname = old.pname + "-customized";
  configureFlags = lib.optionals enableParallel [
    "--enable-parallel"
  ] ++ lib.optionals (!enableGnome) [
    "--disable-gnome"
  ] ++ lib.optionals (!enableCinnamon) [
    "--disable-cinnamon"
  ] ++ lib.optionals (!enableFlashback) [
    "--disable-flashback"
  ] ++ lib.optionals (!enableXfce) [
    "--disable-xfce"
  ] ++ lib.optionals (!enableMate) [
    "--disable-mate"
  ] ++ lib.optionals (!enableOpenbox) [
    "--disable-openbox"
  ] ++ lib.optionals (enableGtkNext) [
    "--enable-gtk_next"
  ] ++ lib.optionals enablePlank [
    "--enable-plank"
  ] ++ lib.optionals enableTelegram [
    "--enable-telegram"
  ] ++ lib.optionals enableTweetdeck [
    "--enable-tweetdeck"
  ] ++ [
    "--with-selection_color=${selectionColor}"
    "--with-accent_color=${accentColor}"
    "--with-suggestion_color=${suggestionColor}"
    "--with-destruction_color=${destructionColor}"
  ];
})
