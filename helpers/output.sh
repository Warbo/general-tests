#!/usr/bin/env bash

[[ -z "$1" ]] && {
    echo "Please give a script name as argument" >> /dev/stderr
    exit 1
}

for ARG in "$@"
do
    NAME=$(basename "$ARG")
    [[ -e "scripts/$NAME" ]] || {
        echo "Could not find 'scripts/$NAME'" >> /dev/stderr
        exit 1
    }

    echo "CONTENTS OF STDOUT (results/stdout/$NAME)"
    cat "results/stdout/$NAME"

    echo "CONTENTS OF STDERR (results/stderr/$NAME)"
    cat "results/stderr/$NAME"
done
