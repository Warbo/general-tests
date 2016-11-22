#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

  F=../results/attrs.json
ERR=../results/attrs.err

CODE=0

function refresh {
    nix-instantiate --show-trace --json --read-write-mode --strict --eval \
                    ../tests.nix 1> "$F" 2> "$ERR" || CODE=1
}

if [[ -e "$F" ]]
then
    if test "$(find "$F" -mmin +10)"
    then
        refresh
    fi
else
    refresh
fi

cat "$ERR" 1>&2
cat "$F"

exit "$CODE"
