{ stdenv
, fetchurl
, gnumake
, system
, ...
}:

stdenv.mkDerivation rec {
  pname = "7zip";
  version = "23.01";

  src = fetchurl {
    url = "https://www.7-zip.org/a/7z2301-src.tar.xz";
    sha256 = "0x4zpzjfnn0ggjprz30fawdvb014icz9j14r9n1a3rb0fc072q1m";
  };

  patches = [ ./000-dangerous-links.patch ];

  arch = {
    "x86_64-darwin" = "x64";
    "aarch64-darwin" = "arm64";
  }.${system} or (throw "unknown system ${system}");

  sourceRoot = ".";

  nativeBuildInputs = [ gnumake ];

  setupHook = ./setup-hook.sh;

  dontConfigure = true;

  buildPhase = ''
    export MACOSX_DEPLOYMENT_TARGET=11.0
    cd CPP/7zip/Bundles/Alone2
    make -f ../../cmpl_mac_${arch}.mak LOCAL_FLAGS_ST=-Wno-extra-semi-stmt
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp b/m_${arch}/7zz $out/bin
  '';

}



