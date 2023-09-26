{ nixpkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs
, pkgs ? import nixpkgs {}
}:

with pkgs;
let 
  inherit (pkgs) lib;
  data = with builtins; fromJSON (readFile ./casks.json);
  sevenzip = darwin.apple_sdk_11_0.callPackage ./7zip { inherit pkgs; };
in
  builtins.listToAttrs (lib.lists.forEach data (cask:
      let 
        artifacts = lib.lists.foldl lib.attrsets.recursiveUpdate {} cask.artifacts;
        app = builtins.elemAt artifacts.app 0;
        lowerurl = lib.strings.toLower cask.url;
      in
        rec {
          name = cask.token;
          value = pkgs.stdenv.mkDerivation ({
            inherit (cask) version;
            pname = name;
            src = fetchurl {
              inherit (cask) url sha256;
            };

            nativeBuildInputs = [ pkgs.makeWrapper ] ++
                  lib.optionals (lib.strings.hasSuffix ".dmg" lowerurl) [ sevenzip ] ++
                  lib.optionals (lib.strings.hasSuffix ".zip" lowerurl) [ pkgs.unzip ];

            setSourceRoot = ''
              sourceRoot="$(dirname "$(find . -name '${app}' | grep -v __MACOSX)")"
            '';

            installPhase = ''
              runHook preInstall
        
              mkdir -p $out/Applications
              cp -r *.app $out/Applications
        
              mkdir -p $out/bin
              for bin in $out/Applications/*.app/Contents/MacOS/*; do
                [[ "$(basename "$bin")" =~ $pname && ! "$bin" =~ \.dylib && -f "$bin" && -x "$bin" ]] &&  makeWrapper "$bin" "$out/bin/$(basename "$bin")"
              done
        
              runHook postInstall
            '';
          } // (if (lib.strings.hasSuffix ".dmg" lowerurl) then {
            inherit sevenzip;
            unpackCmd = ./unpackdmg.sh;
          } else {}));
  }))
