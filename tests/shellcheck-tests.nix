#! /usr/bin/env bash

shopt -s nullglob

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

function msg {
    true
    echo "$1" 1>&2
}

function data {
    my_shellscripts | skip
}

function rawCached {
    ./helpers/cache.sh "$(basename "$0")" < <(data)
}

function skip {
    grep -v "\.rkt$"                |
    grep -v "/haskell-te/packages/" |
    grep -v "/TheoryExplorationBenchmark/modules/" | while read -r F
    do
        if head -n1 < "$F" | grep    "nix-shell"     > /dev/null &&
           head -n2 < "$F" | grep -- "-i runhaskell" > /dev/null
        then
            # Skip Haskell file
            continue
        fi
        if head -n1 < "$F" | grep "racket" > /dev/null
        then
            # Skip Racket file
            continue
        fi
        echo "$F"
    done
}

function cached {
    # Some files may have disappeared since we last cached
    while read -r LINE
    do
        [[ -f "$LINE" ]] && echo "$LINE"
    done < <(rawCached | skip)
}

cached > /dev/null

ERR=0
while read -r script
do
    printf '.'
    shellcheck -e SC1091 -e SC1008 -e SC2001 -e SC2029 "$script" || {
        ERR=1
        [[ "$FULL" -eq 1 ]] || exit 1
    }
done < <(cached)

exit "$ERR"