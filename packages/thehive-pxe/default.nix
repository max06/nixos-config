{stdenv, ...}:
stdenv.mkDerivation {
  pname = "thehive-pxe";
  version = "1.0.0";

  dontUnpack = true;

  # Build script
  buildPhase = ''
    mkdir -p $out
    echo "foo" > $out/predefined-file.txt
  '';
}
