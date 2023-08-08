#!/usr/bin/env bash

downloaded=$(mktemp -p .)
processed=$(mktemp -p .)
exit=0

curl -s -o $downloaded  https://formulae.brew.sh/api/cask.json  &&
  jq -f proccasks.jq < $downloaded > $processed

if [ "$?" = 0 ]; then
  mv -f $processed casks.json
else
  exit=1
fi

rm -f $processed $downloaded
exit $exit
