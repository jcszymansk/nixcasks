{ nixpkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs
, pkgs ? import nixpkgs {}
, osVersion ? "monterey"
}:

with pkgs;
let
  inherit (pkgs) lib;
  data = with builtins; fromJSON (readFile ./casks.json);
  sevenzip = darwin.apple_sdk_11_0.callPackage ./7zip { inherit pkgs; };
  overrides = import ./overrides.nix { inherit pkgs sevenzip; };
  brewyArch = if (lib.strings.hasPrefix "aarch64" pkgs.system) then "arm64_" else "";
  variationId = "${brewyArch}${osVersion}";
in
  builtins.listToAttrs (lib.lists.forEach data (cask:
      let
        artifacts = lib.lists.foldl lib.attrsets.recursiveUpdate {} cask.artifacts;
        app = builtins.elemAt artifacts.app 0;
        /* if artifacs.app has second element, it's a k/v pair "target" -> name to which rename the app */
        rename = if (builtins.length artifacts.app) > 1 then (builtins.elemAt artifacts.app 1).target else app;
        lowerurl = lib.strings.toLower cask.url;
        rawVariation = cask.variations.${variationId} or { inherit (cask) version url sha256; };
        variation = {
          inherit (rawVariation) url sha256;
          version = rawVariation.version or cask.version;
        };
        name = cask.token;
        deriv = rec {
          inherit name;
          value = pkgs.stdenv.mkDerivation ({
            inherit (variation) version;
            pname = name;
            src = fetchurl {
              inherit (variation) url sha256;
            };

            nativeBuildInputs = [ pkgs.makeWrapper ] ++
                  lib.optionals (lib.strings.hasSuffix ".dmg" lowerurl) [ sevenzip ] ++
                  lib.optionals (lib.strings.hasSuffix ".zip" lowerurl) [ pkgs.unzip ];

            setSourceRoot = ''
              sourceRoot="$(dirname "$(find . -name '${app}' | grep -v __MACOSX)")"
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $(dirname $out/Applications/${rename})
              cp -r "${app}" "$out/Applications/${rename}"

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
        };
      in
        if (lib.attrsets.hasAttrByPath [ "${name}" ] overrides)
        then { inherit (deriv) name; value = deriv.value.overrideAttrs overrides."${name}"; }
        else deriv
  ))
