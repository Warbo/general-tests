#!/usr/bin/env bash
set -e

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

DIR=~/Programming/Haskell/AstPlugin
cd "$DIR"
if [[ -d "dist" ]]
then
    rm -r dist
fi
nix-build --show-trace -E 'import ./test.nix'
