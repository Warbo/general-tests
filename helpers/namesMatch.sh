#!/usr/bin/env bash
echo "No name given, check names match up"
PREFIX="$1"

echo "Looking for '$PREFIX' tests"
FOUND=""
for TEST in scripts/"$PREFIX".*
do
    FOUND=$(echo "$FOUND"; echo "$TEST")
done

echo "Checking each cache line has a test"
while read -r LINE
do
    GOT=$(./helpers/mkName.sh "$LINE")
    echo "Looking for test for '$LINE'"
    FILE="$PREFIX.$GOT"
    [[ -e "scripts/$FILE" ]] || {
        echo "No such file '$FILE', making it"
        pushd scripts                    &&
            ln -s "$PREFIX" "$FILE"      &&
            popd                         &&
            touch "results/stdout/$FILE" &&
            touch "results/stderr/$FILE"
    } || exit 1

    # Remove this file from $FOUND, if present
    FOUND=$(echo "$FOUND" | grep -v "^scripts/${FILE}$")
done

[[ -z "$FOUND" ]] || {
    echo "Found spurious tests:"
    echo "$FOUND" | grep -v '^$'
    echo "These don't correspond to cache lines"
    exit 1
} >> /dev/stderr
