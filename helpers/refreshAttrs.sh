#!/usr/bin/env bash

  F=../results/attrs.json
ERR=../results/attrs.err

cd "$(dirname "$(readlink -f "$0")")"

function go {
    nix-instantiate --read-write-mode --eval \
                    -E 'import ./testPaths.nix' 2> >(tee "$ERR" 1>&2) |
        jq -r '.'   |
        jq -c '.[]' |
        tee "$F.new"
    mv "$F.new" "$F"
}

if [[ -n "$HAVE_LOCK" ]]
then
    go
else
    (
        flock -n 9 || {
            echo "Couldn't aquire lock, is another instance running?" 1>&2
            exit 1
        }
        go
    ) 9>/tmp/tests.lock
fi
