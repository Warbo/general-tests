{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

# Look for "test.sh" or "tests.sh" scripts, and make sure they're included in a
# test script

function data {
    locate -e "* /test.sh"
    locate -e "* /tests.sh"
}

function cached {
    ./helpers/cache.sh "test-scripts-included" < <(data) | skip
}

function skip {
    # Ignore anything in the Nix store
    grep -v "/nix/store/"                          |
    # Ignore temporary files
    grep -v "/tmp"                                 |
    # Ignore anything in Backups, since it's unmaintained
    grep -v "/Backups/"                            |
    # Ignore the git clones made by git2html
    grep -v "/git-html/"                           |
    grep -v "/System/Programs"                     |
    # Specific tests which aren't under our control
    grep -v "/NotMine"                             |
    grep -v "/home/chris/Programming/Haskell/ghc/" |
    # Ignore any code being cached by static analysis tools
    grep -v "/home/chris/.cache"                   |
    # Ignore the git submodules of haskell-te
    grep -v "/haskell-te/packages/"
}

echo "Filling cache"
cached > /dev/null
echo "Cache filled"

function fail {
    echo "FAIL: $1" 1>&2
    [[ "$FULL" -eq 1 ]] || exit 1
}

function containsImmediateDirectory {
    NAME=$(basename "$(dirname "$(readlink -f "$1")")")
    grep "/$NAME" > /dev/null
}

function isScriptCalledBy {
    # It's very unlikely that a script will be called without its filename being
    # mentioned
    NAME=$(basename "$1")
    grep "$NAME" < "$2" > /dev/null || return 1

    # Since we're looking for generic script names like "test.sh", we need to go
    # up a level and check the directory name too. This is tricky, as it might
    # involve wildcards, relative paths, etc.

    # Get the next directory up
    DIR=$(basename "$(dirname "$(readlink -f "$1")")")

    # If it looks sufficiently unique, and is found, then count it as a success
    if seemsSufficient "$DIR"
    then
        grep "/$DIR" < "$2" > /dev/null
    else
        thoroughCheck "$1" "$2"
    fi
}

function seemsSufficient {
    ! echo "$1" | grep "test" > /dev/null
}

function thoroughCheck {
    # Strip off /home/chris/Foo/
    SPECIFIC=$(dirname "$(echo "$1" | sed -e 's@/home/chris/[^/]* /@@g')")

    # Look for this directory in our test
    grep "$SPECIFIC" < "$2" > /dev/null
}

function checkScriptCalled {
    echo "Making sure a test runs '$1'"

    for TEST in scripts/*
    do
        isScriptCalledBy "$1" "$TEST" && {
            echo "Test '$TEST' seems to contain '$1'"
            return 0
        }
    done

    fail "Couldn't find a test which runs '$1'"
}

while read -r SCRIPT
do
    checkScriptCalled "$SCRIPT"
done < <(cached)
*/
