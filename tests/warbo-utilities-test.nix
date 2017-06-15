#!/usr/bin/env bash

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

DIR=~/warbo-utilities
cd "$DIR" || fail "Couldn't cd to '$DIR'"
./test.sh
