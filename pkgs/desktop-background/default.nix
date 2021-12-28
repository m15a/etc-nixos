{ runCommandNoCC }:

runCommandNoCC "desktop-background" {} ''
  cp ${./desktop_background.jpg} $out
''
