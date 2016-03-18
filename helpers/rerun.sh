#!/usr/bin/env bash

FILE=$(readlink -f "$0")
DIR=$(dirname "$FILE")
if failed_tests | grep "00FF00" > /dev/null
then
    "$DIR/
else
fi
