#!/usr/bin/env bash

# Retry failing tests if we have any
if failed_tests | grep "#FF0000" > /dev/null
then
    ./run
else
    ./helpers/times.sh | ./helpers/choose.hs
fi
