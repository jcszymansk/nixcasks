#!/usr/bin/env bash

downloaded=$(mktemp -p .)
exit=0

curl -s -o $downloaded  https://formulae.brew.sh/api/cask.json 

if [ "$?" = 0 ]; then
  mv -f $downloaded casks.json
else
  exit=1
fi

rm -f $downloaded
exit $exit
