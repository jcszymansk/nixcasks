{ nixpkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs
, pkgs ? import nixpkgs {}
}:

with pkgs;
let 
  inherit (pkgs) lib;
  data = with builtins; fromJSON (readFile ./casks.json);
in
  builtins.listToAttrs (lib.lists.forEach data (cask: rec {
    inherit (cask) name;
    value = pkgs.stdenv.mkDerivation ({
      inherit (cask) version;
      pname = name;
      src = fetchurl {
        inherit (cask) url sha256;
      };

      nativeBuildInputs = [ pkgs.makeWrapper ] ++
        lib.optionals (lib.strings.hasSuffix ".zip" cask.url) [ pkgs.unzip ];

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
  
        mkdir -p $out/Applications
        cp -r *.app $out/Applications
  
        mkdir -p $out/bin
        for bin in $out/Applications/*.app/Contents/MacOS/*; do
          [[ ! "$bin" =~ \.dylib && -f "$bin" && -x "$bin" ]] &&  makeWrapper "$bin" "$out/bin/$(basename "$bin")"
        done
  
        runHook postInstall
      '';

   } // (if (lib.strings.hasSuffix ".dmg" cask.url) then {
     unpackCmd = ./unpackdmg.sh;
   } else { }));
  }))
