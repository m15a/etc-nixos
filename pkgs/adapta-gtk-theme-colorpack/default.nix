{ stdenv, fetchurl, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  pname = "adapta-gtk-theme-colorpack";
  version = "3.94.0.149";

  src = fetchurl {
    url = "https://github.com/ivankra/${pname}/releases/download/${version}-colorpack/${pname}_${version}.tar";
    sha256 = "09n8pzh0i5z42pplnhhbhp6z9qgcfrb07sxx3a3qlqnk422cpamz";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/themes"
    tar xf "$src" -C "$out/share/themes"
    rm "$out/share/themes"/*/{COPYING,LICENSE*,README*}
  '';

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = with stdenv.lib; {
    description = "Adapta GTK+ theme with a variety of material design colors";
    homepage = "https://github.com/ivankra/adapta-gtk-theme-colorpack";
    license = with licenses; [ gpl2 cc-by-sa-30 ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ mnacamura ];
  };
}
