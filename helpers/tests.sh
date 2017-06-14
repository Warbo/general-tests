#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

  F=../results/attrs.json
ERR=../results/attrs.err

# Speeds up latestGit
while read -r VAR
do
    N=$(echo "$VAR" | cut -f1)
    V=$(echo "$VAR" | cut -f2)
    export "$N"="$V"
done < <(gitRevEnvVars)

function now {
    date "+%s"
}

function refresh {
    while read -r PTH
    do
        if [[ "x$MODE" = "xfailed" ]] && ! [[ -f ../results/fail/"$PTH" ]]
        then
            continue
        fi

        now > ../results/running/"$PTH"
        printf 'Test %s: ' "$PTH" 1>&2
        if echo "$PTH" | ./runByPath.sh 1> ../results/stdout/"$PTH" \
                                        2> ../results/stderr/"$PTH"
        then
            now > ../results/pass/"$PTH"
            rm -f ../results/fail/"$PTH" 2> /dev/null
            echo "PASS" 1>&2
        else
            now > ../results/fail/"$PTH"
            rm -f ../results/pass/"$PTH" 2> /dev/null
            echo "FAIL" 1>&2
        fi
        rm -f ../results/running/"$PTH"
    done < <(getPaths | jq -c 'path(..|select(type=="string"))')
}

function getPaths {
    nix-instantiate --show-trace --json --read-write-mode --strict --eval \
                    -E 'import ../tests.nix {}' 1> >(tee "$F.new") \
                                                2> >(tee "$ERR" 1>&2)
    mv "$F.new" "$F"
}

# Bail out if we can't get a lock; only one running at a time
(
    flock -n 9 || {
        echo "Couldn't aquire lock, is another instance running?" 1>&2
        exit 1
    }
    refresh
) 9>/tmp/tests.lock
