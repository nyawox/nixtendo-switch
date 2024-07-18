{
  lib,
  stdenv,
  makeWrapper,
  jre,
  libGL,
  libXtst,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "uScreen";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/XorTroll/uLaunch/releases/download/1.0.0/uScreen.jar";
    sha256 = "1gs2q0jf1gpk20gvw3f1g7h63vs0hbgya17h3gvfczri1rsx7pnz";
  };

  nativeBuildInputs = [makeWrapper];

  buildInputs = [jre libGL libXtst];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/java $out/bin
    cp $src $out/share/java/uScreen.jar

    makeWrapper ${jre}/bin/java $out/bin/uScreen \
      --add-flags "-jar $out/share/java/uScreen.jar" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libGL libXtst]}
  '';

  meta = with lib; {
    description = "a Java tool for USB screen capturing hacked switch";
    homepage = "https://github.com/XorTroll/uLaunch";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
