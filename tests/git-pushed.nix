#!/usr/bin/env bash

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

function fail {
    msg "FAIL: $1"
    ERR=1
    [[ "$FULL" -eq 1 ]] || exit 1
}

function repos {
    # Find git repos based on their .git directories
    locate -e "/home/chris/*/.git" | skip
}

function msg {
    echo -e "$1" 1>&2
}

function remotes {
    # We should always be pushing to origin and github; we don't enforce
    # anything else since they're case-by-case. For example, we might
    # have a read-only "upstream" for fetching, with pushes going via
    # pull requests from "github"
    git remote | grep -e '\(origin\|github\)'
}

function branches {
    git branch | cut -c 3- | grep -v '^('
}

function checkBranch {
    git ls-remote "$1" 2> /dev/null | cut -f 2 |
                                      grep -Fx "refs/heads/$2" > /dev/null || {
        fail "'$REPO' branch '$BRANCH' not on remote '$1'"
        return 1
    }
}

function data {
    while read -r GITDIR
    do
        dirname "$GITDIR"
    done < <(repos)

    # Include all our bare repos
    ls -d1 /home/chris/Programming/repos/*.git
}

function skip {
    grep -v "opencl-horde"          |
    grep -v "/Backups/"             |
    grep -v "/git-html"             |
    grep -v "/System/Programs"      |
    grep -v "/NotMine/"             |
    grep -v "/OldCode/"             |
    grep -v "/Marking/"             |
    grep -v "/haskell-te/packages/" |
    grep -v "\.stack"               |
    grep -v "/TheoryExplorationBenchmark/modules/"
}

function cached {
    ./helpers/cache.sh "git-pushed" < <(data | skip) | skip
}

cached > /dev/null

ERR=0

function checkRepos {
    while read -r REPO
    do
        [[ -e "$REPO" ]] || { echo "Skipping non-existent '$REPO'"; continue; }
        echo "Checking '$REPO'" 1>&2

        pushd "$REPO" > /dev/null

        # Skip repos with no remote
        [[ -z "$(git remote)" ]] && continue

        checkRemotes

        popd > /dev/null
    done < <(cached)
}

function checkRemotes {
    # Look for unpushed commits and missing branches. `git status` also lists
    # unpushed commits but it doesn't work in bare repos
    while read -r REMOTE
    do
        checkBranches "$REMOTE"
    done < <(remotes)
}

function checkBranches {
    MISSINGBRANCHES=0
    while read -r BRANCH
    do
        checkBranch "$1" "$BRANCH" || MISSINGBRANCHES=1
    done < <(branches)
    return "$MISSINGBRANCHES"
}

checkRepos

exit "$ERR"