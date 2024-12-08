{ pkgs ? import (builtins.getFlake(toString ./.)).inputs.nixpkgs {}
, osVersion ? "ventura"
, localAdditions ? ./local
, localArgs ? {}
, ...
}:

with pkgs;
let
  inherit (pkgs) lib;
  sevenzip = darwin.apple_sdk_11_0.callPackage ./7zip { inherit pkgs; };
  nclib = import ./nclib.nix { inherit pkgs sevenzip; };
  defaultImportArgs = { inherit pkgs sevenzip nclib; };
  data = with builtins; fromJSON (readFile ./casks.json);
  localOverrides =
    let loPath = "${localAdditions}/overrides.nix"; 
    in if (builtins.pathExists loPath) 
      then import loPath (defaultImportArgs // localArgs)
      else {};
  overrides = (import ./overrides.nix defaultImportArgs) // localOverrides;
  brewyArch = if (lib.strings.hasPrefix "aarch64" pkgs.system) then "arm64_" else "";
  variationId = "${brewyArch}${osVersion}";
in
  builtins.listToAttrs (lib.lists.forEach data (cask:
      let
        artifacts = lib.lists.foldl lib.attrsets.recursiveUpdate {} cask.artifacts;

        /* no filtering in jq anymore, now all apps are accepted, those that would be
           filtered are marked broken, but they can be "unbroken" in overrides.
         */
        noCheck = (cask.sha256 or "no_check") == "no_check";
        hasPkg = lib.hasAttr "pkg" artifacts;
        hasInstaller = lib.hasAttr "installer" artifacts;
        broken = noCheck || hasPkg || hasInstaller;

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

            dontPatch = true;
            dontConfigure = true;
            dontBuild = true;
            dontFixup = true;

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

            meta.broken = broken;
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
