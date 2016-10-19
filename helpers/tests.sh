#!/usr/bin/env bash
set -e

cd "$(dirname $(readlink -f "$0"))"

F=../results/attrs.json

function refresh {
    nix-instantiate --json --read-write-mode --strict --eval ../tests.nix > "$F"
}

if [[ -e "$F" ]]
then
    if test $(find "$F" -mmin +10)
    then
        refresh
    fi
else
    refresh
fi

cat "$F"
