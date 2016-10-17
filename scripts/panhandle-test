#! /usr/bin/env nix-shell
#! nix-shell -i bash -p haskellPackages.cabal-install

function fail {
    echo "FAIL $1" 1>&2
    exit 1
}

DIR=~/Programming/Haskell/pan-handler
cd "$DIR" || fail "Couldn't cd to '$DIR'"

./test.sh
