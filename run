#!/usr/bin/env bash

cd "$(dirname "$(readlink -f "$0")")"

F=../results/attrs.json

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

function go {
    HAVE_LOCK=1 ./refreshAttrs.sh
    while read -r PTH
    do
        if [[ "x$MODE" = "xfailed" ]] && ! [[ -f ../results/fail/"$PTH" ]]
        then
            continue
        fi

        if [[ "x$MODE" = "xgiven" ]] &&
               echo "$GIVEN" | jq -e --argjson pth "$PTH" \
                                  'map(. != $pth) | all' > /dev/null
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
    done < "$F"
}

if [[ -n "$HAVE_LOCK" ]]
then
    go
else
    (
        flock -n 9 || {
            echo "Couldn't get lock; are other tests running?" 1>&2
            exit 1
        }
        go
    ) 9>/tmp/tests.lock
fi
