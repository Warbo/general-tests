#!/usr/bin/env bash

shopt -s nullglob

# Coverage below this percentage will cause a failure
MINIMUM=30

function skip {
    cat
}

function data {
    # When a test suite passes, it should store its coverage report here
    find ~/Programming/coverage -name "hpc_index.html" | skip
}

function cached {
    ./helpers/cache.sh "hpc-coverage" < <(data) | skip
}

# Prime the cache
cached > /dev/null
mkdir -p ~/Programming/coverage

# Check how we were called
if NAME=$(./helpers/getName.sh "$0")
then
    LINES=$(./helpers/checkNames.sh "$NAME" < <(cached)) || exit 1
    while read -r LINE
    do
        TOTAL='th[contains(text(),"Program Coverage Total")]'
        PERCENT='following-sibling::td[1]/text()'
        RAW=$(xidel - --extract "//${TOTAL}/${PERCENT}" < "$LINE")
        RESULT=$(echo "$RAW" | tr -d '%')
        echo "File '$LINE' has coverage '$RAW'"
        if echo "$RESULT" | grep "[^0-9]" > /dev/null
        then
            # 0 shows up as "-", so fix it
            echo "Percentage looks non-numeric; assuming 0"
            RESULT=0
        fi
        if [[ "$RESULT" -lt "$MINIMUM" ]]
        then
            echo "'$RESULT' coverage for '$LINE'" 1>&2
            exit 1
        fi
    done < <(echo "$LINES")
else
    ./helpers/namesMatch.sh "hpc-coverage" < <(cached) || exit 1
fi
