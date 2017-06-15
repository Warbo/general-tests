#!/usr/bin/env bash

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

DIR=~/Programming/Haskell/MLSpec
cd "$DIR" || fail "Couldn't cd to '$DIR'"

# Make sure test files are in the same format as ML4HS is producing
[[ "$(find test-data -type f -name "*format*" | wc -l)" -gt 0 ]] ||
    fail "Didn't find any formatted test-data"

hsConfig || fail "hsConfig failed"

./test.sh
