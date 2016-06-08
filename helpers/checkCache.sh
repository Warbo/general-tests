#!/usr/bin/env bash

CACHECOUNT=$(cat | wc -l)
FILECOUNT=$(find scripts -name "*.$1" | wc -l)
if [[ "$CACHECOUNT" -eq "$FILECOUNT" ]]
then
    echo "Got enough tests to cover '$1'"
else
    echo "Have $FILECOUNT test(s) for $CACHECOUNT files" 1>&2
    exit 1
fi
