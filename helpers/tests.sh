#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

F=../results/attrs.json

# Bail out if we can't get a lock; only one running at a time
(
    flock -n 9 || {
        echo "Couldn't aquire lock, is another instance running?" 1>&2
        exit 1
    }
    if ! [[ -e "$F" ]] || test "$(find "$F" -mmin +30)"
    then
        HAVE_LOCK=1 ./refreshAttrs.sh
    fi
    HAVE_LOCK=1 ./runTests.sh
) 9>/tmp/tests.lock
