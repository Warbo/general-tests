#! /usr/bin/env nix-shell
#! nix-shell --show-trace -i bash

function run {
    make -k -j2 "$@"
}

# Check that arguments refer to tests
NAMES=()
for ARG in "$@"
do
    # Strip off any path; we want "scripts/foo" to be "foo", since the former is
    # a file, and hence we get tab-completion for free
    NAME=$(basename "$ARG")

    [[ -e "scripts/$NAME" ]] || {
        echo "Could not find 'scripts/$NAME'" >> /dev/stderr
        exit 1
    }

    NAMES+=( "$NAME" )
done

# Force re-execution of tests by deleting previous "pass" files, if any
RESULTS=()
for NAME in "${NAMES[@]}"
do
    RESULT="results/pass/$NAME"
    rm -f "$RESULT"
    RESULTS+=( "$RESULT" )
done

if [[ "$#" -eq 0 ]]
then
    echo "No tests given, running all" >> /dev/stderr
    run all
else
    run "${RESULTS[@]}"
fi
