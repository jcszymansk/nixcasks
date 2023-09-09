#!/bin/sh

# from https://discourse.nixos.org/t/help-with-error-only-hfs-file-systems-are-supported-on-ventura/25873/8
env
echo "File to unpack: $src"
if ! [[ "$src" =~ \.[Dd][Mm][Gg]$ ]]; then exit 1; fi
mnt=$(mktemp -d -t ci-XXXXXXXXXX)

function finish {
  echo "Detaching $mnt"
  /usr/bin/hdiutil detach $mnt -force
  rm -rf $mnt
}
trap finish EXIT

echo "Attaching $mnt"
/usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

echo "What's in the mount dir"?
ls -la $mnt/

echo "Copying contents"
shopt -s extglob
DEST="$PWD"
(cd "$mnt"; cp -a !(Applications) "$DEST/")

