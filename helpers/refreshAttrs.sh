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

nix-instantiate --show-trace --json --read-write-mode --strict --eval \
                -E 'import ../tests.nix {}' \
                1> >(jq -c 'path(..|select(type=="string"))' | tee "$F.new") \
                2> >(tee "$ERR" 1>&2)

mv "$F.new" "$F"
