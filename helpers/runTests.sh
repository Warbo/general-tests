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