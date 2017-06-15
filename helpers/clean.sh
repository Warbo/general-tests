#!/usr/bin/env bash

set -e

cd "$(dirname "$(readlink -f "$0")")"

PTHS=$(./refreshAttrs.sh)

for F in ../results/pass/* ../results/fail/*
do
    FOUND=0
    NAME=$(basename "$F")
    while read -r PTH
    do
        if [[ "x$NAME" = "x$PTH" ]]
        then
            FOUND=1
        fi
    done < <(echo "$PTHS")

    if [[ "$FOUND" -eq 0 ]]
    then
        rm -v "$F"
    fi
done
