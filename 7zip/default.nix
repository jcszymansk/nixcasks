{ stdenv
, fetchurl
, gnumake
, system
, _7zz
, ...
}:

_7zz.overrideAttrs (prev: {
  patches = prev.patches ++ [ ./000-dangerous-links.patch ];
})
