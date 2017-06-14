#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

function getPaths {
    if ! [[ -e "$F" ]] || test "$(find "$F" -mmin +30)"
    then
        ./refreshAttrs.sh
    else
        cat "$F"
    fi
}

# Bail out if we can't get a lock; only one running at a time
(
    flock -n 9 || {
        echo "Couldn't aquire lock, is another instance running?" 1>&2
        exit 1
    }
    getPaths | ./runscript.sh
) 9>/tmp/tests.lock
