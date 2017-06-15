{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

function data {
    locate -e '/home/chris/Programming/ * /.git' |
    grep -v "/git-html/" |
    grep -v "/ATS/aos"
}

CACHE="results/data/all-committed"
function cached {
    if [[ -e "$CACHE" ]] && test "$(find "$CACHE" -mmin -60)"
    then
        cat "$CACHE"
    else
        data | tee "$CACHE"
    fi
}

function gitClean {
    if ! git status | grep "nothing to commit, working directory clean" > /dev/null
    then
        ERR=1
        echo "Uncommited things in '$1'" 1>&2
        [[ "$FULL" -eq 1 ]] || exit 1
    fi
}

ERR=0
while IFS= read -r REPO
do
    DIR=$(dirname "$REPO")
    [[ -e "$DIR" ]] || continue
    cd "$DIR" || { ERR=1; continue; }
    gitClean "$DIR"
done < <(cached)

exit "$ERR"
*/
