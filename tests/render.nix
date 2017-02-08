#!/usr/bin/env bash

function data {
    locate -e "/home/chris/Writing/*/render.sh"
}

function cached {
    ./helpers/cache.sh "render" < <(data)
}

cached > /dev/null

if NAME=$(./helpers/getName.sh "$0")
then
    LINES=$(./helpers/checkNames.sh "$NAME" < <(cached)) || exit 1
    while read -r SCRIPT
    do
        DIR=$(dirname "$SCRIPT")
        pushd "$DIR"
        if ! ./render.sh
        then
            echo "$SCRIPT failed" 1>&2
            exit 1
        fi
    done < <(echo "$LINES")
else
    ./helpers/namesMatch.sh "render" < <(cached) || exit 1
fi
