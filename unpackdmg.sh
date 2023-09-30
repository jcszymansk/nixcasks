#!/bin/bash

# from https://discourse.nixos.org/t/help-with-error-only-hfs-file-systems-are-supported-on-ventura/25873/8
echo "File to unpack: $src"
if ! [[ "$src" =~ \.[Dd][Mm][Gg]$ ]]; then exit 1; fi

mnt=$(mktemp -d -t ci-XXXXXXXXXX)

function finish {
  rm -rf $mnt
}
trap finish EXIT

if ! "$sevenzip"/bin/7zz t $src >/dev/null 2>&1; then

  cnv=$mnt/$(basename $src)

  echo "converting $mnt"
  /usr/bin/hdiutil convert -format UDBZ -o $cnv $src
  src=$cnv

fi
echo "unpacking $src"
"$sevenzip"/bin/7zz  -snld x $src
