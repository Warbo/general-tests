#!/usr/bin/env bash

  F=../results/attrs.json
ERR=../results/attrs.err

cd "$(dirname "$(readlink -f "$0")")"

# Speeds up latestGit
while read -r VAR
do
    N=$(echo "$VAR" | cut -f1)
    V=$(echo "$VAR" | cut -f2)
    export "$N"="$V"
done < <(gitRevEnvVars)

function go {
    nix-instantiate --show-trace --json --read-write-mode --strict --eval \
                    -E 'import ../tests.nix {}' \
                    1> >(jq -c 'path(..|select(type=="string"))' | tee "$F.new") \
                    2> >(tee "$ERR" 1>&2)

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
