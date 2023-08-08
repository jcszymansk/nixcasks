{ stdenv
, fetchurl
, gnumake
, ...
}:

stdenv.mkDerivation {
  pname = "7zip";
  version = "23.01";

  src = fetchurl {
    url = "https://www.7-zip.org/a/7z2301-src.tar.xz";
    sha256 = "0x4zpzjfnn0ggjprz30fawdvb014icz9j14r9n1a3rb0fc072q1m";
  };

  sourceRoot = ".";

  patches = [ ./01-unused-warning.patch ];

  nativeBuildInputs = [ gnumake ];

  setupHook = ./setup-hook.sh;

  dontConfigure = true;

  buildPhase = ''
    export MACOSX_DEPLOYMENT_TARGET=11.0
    cd CPP/7zip/Bundles/Alone2
    make -f ../../cmpl_mac_x64.mak
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp b/m_x64/7zz $out/bin
  '';

}



