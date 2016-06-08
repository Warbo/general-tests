#!/usr/bin/env bash

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

# Tests that we can look up the latest revision of a Git repository, cache it to
# avoid subsequent lookups, run cabal2nix on the repo contents and instantiate
# the result using haskellPackages.callPackage

echo "Making sure nix-eval.nix exists, and is using haskellGit"

FOUND=0
while read -r FILE
do
    if grep "haskellGit" < "$FILE" > /dev/null
    then
        FOUND=1
    else
        fail "No haskellGit found in '$FILE'"
    fi
done < <(find ~/.nixpkgs -name "nix-eval.nix" | grep "haskell")

[[ "$FOUND" -eq 1 ]] || fail "Couldn't find haskell/nix-eval.nix"

echo "OK, we can use nix-eval to test haskellGit"

echo "Checking if nix_git_rev_... is set inside nix-shell"
OUTPUT=$(nix-shell --show-trace -p nix-eval --run \
         'env | grep nix_git_rev')

echo "$OUTPUT" | grep "^nix_git_rev_" > /dev/null ||
    fail "No nix_git_rev_... variables were set: $OUTPUT"

echo "Found nix_git_rev... in shell environment"

echo "Running nested nix-shells"
OUTPUT=$(nix-shell --show-trace -p nix-eval --run \
        'nix-shell --show-trace -p nix-eval --run true' 2>&1)
echo "$OUTPUT"

echo "Making sure we only checked git repos at most once"
SEEN=""
while read -r LINE
do
    URL=$(echo "$LINE" | sed -e 's/.*repo-head-//g' | grep -o '[a-z0-9]*')
    STAMP=$(echo "$LINE" | sed -e 's@.*store/@@g' | sed -e 's@-repo-head-.*@@g')
    ENTRY=$(echo -e "$URL\t$STAMP")
    while read -r STAMPS
    do
        FST=$(echo "$STAMPS" | cut -f2)
        SND=$(echo "$STAMPS" | cut -f3)
        [[ "x$FST" = "x$SND" ]] && fail "Multiple timestamps for '$URL'"
    done < <(join <(echo "$SEEN") <(echo "$ENTRY"))
    SEEN=$(echo "$SEEN"; echo "$ENTRY")
done < <(echo "$OUTPUT" | grep "^building path.*repo-head")

echo "Looks OK"
