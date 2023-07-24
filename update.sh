#!/usr/bin/env bash

curl -s https://formulae.brew.sh/api/cask.json | jq -f proccasks.jq > casks.json
