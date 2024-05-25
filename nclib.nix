{ pkgs, sevenzip, ... }:

let
  inherit (pkgs) lib fetchurl;
in
{
  noSandbox = _: { __noChroot = true; };
  broken = _: { meta.broken = true; };
  force-dmg = prev: {
    inherit sevenzip;
    forcedmg = true;
    nativeBuildInputs = prev.nativeBuildInputs ++ [ sevenzip ];
    unpackCmd = ./unpackdmg.sh;
  };
}
