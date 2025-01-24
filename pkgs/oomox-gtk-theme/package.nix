{
  stdenv,
  writeText,
  fetchFromGitHub,
  bc,
  sassc,
  glib,
  gdk-pixbuf,
  librsvg,
  themeNameSuffix ? "generated",
  hidpi ? false,
  makeOpts ? "gtk320",
  BG ? "888a85",
  FG ? "0e0021",
  BTN_BG ? "85509b",
  BTN_FG ? "0e0021",
  HDR_BG ? "0e0021",
  HDR_FG ? "888a85",
  HDR_BTN_BG ? "85509b",
  HDR_BTN_FG ? "0e0021",
  SEL_BG ? "dc5e86",
  SEL_FG ? "000000",
  TXT_BG ? "c0bbbb",
  TXT_FG ? "000000",
  WM_BORDER_FOCUS ? "9edc60",
  WM_BORDER_UNFOCUS ? "0e0021",
  GRADIENT ? 0.0,
  ROUNDNESS ? 4,
  SPACING ? 3,
}:

let
  preset = writeText "oomox-gtk-theme-${themeNameSuffix}-preset" ''
    BG=${BG}
    FG=${FG}
    BTN_BG=${BTN_BG}
    BTN_FG=${BTN_FG}
    HDR_BG=${HDR_BG}
    HDR_FG=${HDR_FG}
    HDR_BTN_BG=${HDR_BTN_BG}
    HDR_BTN_FG=${HDR_BTN_FG}
    SEL_BG=${SEL_BG}
    SEL_FG=${SEL_FG}
    TXT_BG=${TXT_BG}
    TXT_FG=${TXT_FG}
    WM_BORDER_FOCUS=${WM_BORDER_FOCUS}
    WM_BORDER_UNFOCUS=${WM_BORDER_UNFOCUS}
    GRADIENT=${toString GRADIENT}
    ROUNDNESS=${toString ROUNDNESS}
    SPACING=${toString SPACING}
  '';
  themeName = "Oomox-${themeNameSuffix}";
in

stdenv.mkDerivation rec {
  pname = "oomox-gtk-theme-${themeNameSuffix}";
  version = "1.12.8";
  src = fetchFromGitHub {
    owner = "themix-project";
    repo = "oomox-gtk-theme";
    rev = version;
    hash = "sha256-TxMSH1FZogDyYr5ZhQsJAWFMg+9enZE/2xDncvI+whg=";
  };
  nativeBuildInputs = [
    bc
    sassc
    glib
    gdk-pixbuf
    librsvg
  ];
  postPatch = ''
    patchShebangs .
  '';
  buildPhase = ''
    runHook preBuild
    export HOME=.
    ./change_color.sh ${preset} \
        --output ${themeName} \
        --hidpi ${if hidpi then "true" else "false"} \
        --make-opts ${makeOpts}
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -r .themes/${themeName} $out/share/themes/${themeName}
    runHook postInstall
  '';
}
