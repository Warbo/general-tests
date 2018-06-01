{ helpers, pkgs }:
helpers.notImplemented "haskell-te-test"

/*
#!/usr/bin/env bash

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

DIR=~/Programming/haskell-te/tests/.. # Appeases test-scripts-included
cd "$DIR" || fail "Couldn't cd to '$DIR'"

# This sets up the environment for tests/test.sh
./test.sh
*/
