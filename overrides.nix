{ pkgs, sevenzip, nclib, ... }:

let
  inherit (pkgs) lib fetchurl;
in
{
  macpass = _: { setSourceRoot = "sourceRoot=."; };
  docker = nclib.noSandbox;
  little-snitch = nclib.broken;
  sage = _: { meta.broken = false; };
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
    lib.attrsets.genAttrs eclipses (name: nclib.force-dmg)
)
