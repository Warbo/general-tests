#!/usr/bin/env bash

function chooseAndRun {
    # If there are test failures, stop re-testing
    if failed_tests | grep "FF0000" > /dev/null
    then
        exit 1
    fi

    # Otherwise, choose a random test and run it
    CHOSEN=$(./helpers/choose.sh)
    ./run "$CHOSEN"
}

while chooseAndRun
do
    sleep 5
done
