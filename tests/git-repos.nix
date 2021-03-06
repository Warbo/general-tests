{ helpers, pkgs }:
helpers.notImplemented "git-repos"

/*
#!/usr/bin/env bash

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

shopt -s nullglob

function isGit {
    (cd "$1" && git rev-parse --show-toplevel 1> /dev/null 2> /dev/null)
}

function isSvn {
    svn info "$1" 2> /dev/null 1> /dev/null
}

function isDarcs {
    (cd "$1" && darcs show files > /dev/null 2> /dev/null)
}

function isHg {
    hg --cwd "$1" root 2> /dev/null 1> /dev/null
}

function isBzr {
    if bzr check --tree "$1" 2>&1 |
       grep "No working tree found at specified location." > /dev/null
    then
        return 1
    fi
    return 0
}

function isCVS {
    [[ -d "$1/CVS" ]]
}

function isVC {
    isCVS "$1" || isGit "$1" || isSvn "$1" || isDarcs "$1" || isHg "$1" || isBzr "$1"
}

function skip {
    grep -v "Programming/git-html" |
    grep -v "Programming/coverage" |
    grep -v "\.git"                |
    grep -v "\.svn"                |
    grep -v "CVS"                  |
    grep -v "Programming/NotMine"  |
    grep -v "Programming/repos"
}

FAILS="results/data/git-repos"
function cached {
    mkdir -p results/data

    if [[ -e "$FAILS" ]] && test "$(find "$FAILS" -mmin -60)"
    then
        cat "$FAILS"
    fi

    # Always include the root
    echo "/home/chris/Programming"
}

# Make sure everything in ~/Programming is version controlled
ERR=0

DIRS=$(cached) # Dirs we're looping through (immutable during the loop)
NEW=""         # Dirs to loop through next (switched for $DIRS after each loop)
PREV=""        # Remember the last output, to prevent repeating it

# Loop over $DIRS, replacing it with $NEW after each iteration, until $NEW is ""
while [[ -n "$DIRS" ]]
do
    while read -r D
    do
        # Loop through the contents of each directory
        [[ -z "$D" ]] && continue
        for ENTRY in "$D/"*
        do
            [[ -z "$ENTRY" ]] && continue

            # If this entry is a directory, look inside
            if [[ -d "$ENTRY" ]]
            then
                # If it's in version-control, ignore it
                if ! isVC "$ENTRY"
                then
                    NEW=$(printf "%s\n%s" "$NEW" "$ENTRY")
                fi
            else
                # We have a file. What directory is it in?
                DN=$(dirname "$ENTRY")

                # Avoid repeating ourselves
                [[ "x$DN" = "x$PREV" ]] && continue
                PREV="$DN"

                # Report anything which isn't version controlled
                if ! isVC "$DN"
                then
                    echo "$ENTRY doesn't look version controlled" 1>&2

                    # Remember this entry for next time
                    echo "$DN" >> "$FAILS"

                    # Remember the failure
                    ERR=1
                    [[ "$FULL" -eq 1 ]] || exit 1
                fi
            fi
        done
    done < <(echo "$DIRS")
    DIRS=$(echo "$NEW" | skip)
    NEW=""
done

exit "$ERR"
*/
