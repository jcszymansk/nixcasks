{ pkgs, sevenzip }:

let
  inherit (pkgs) lib fetchurl;
  noSandbox = _: { __noChroot = true; };
  broken = _: { meta.broken = true; };
  force-dmg = prev: {
    inherit sevenzip;
    forcedmg = true;
    nativeBuildInputs = prev.nativeBuildInputs ++ [ sevenzip ];
    unpackCmd = ./unpackdmg.sh;
  };
in
{
  macpass = _: { setSourceRoot = "sourceRoot=."; };
  docker = noSandbox;
  little-snitch = broken;
} // (
  let
    eclipses = [
      "eclipse-cpp"
      "eclipse-dsl"
      "eclipse-ide"
      "eclipse-installer"
      "eclipse-java"
      "eclipse-javascript"
      "eclipse-jee"
      "eclipse-modeling"
      "eclipse-php"
      "eclipse-platform"
      "eclipse-rcp"
      "eclipse-testing"
    ];
  in
    lib.attrsets.genAttrs eclipses (name: force-dmg)
)
