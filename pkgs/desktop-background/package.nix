{ runCommandNoCC }:

runCommandNoCC "desktop-background" { } ''
  cp ${./desktop-background.jpg} $out
''
