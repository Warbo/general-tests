{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

echo "Making sure warbo-utilities.nix exists, and is using withLatestGit"

FOUND=0
while read -r FILE
do
    if grep "withLatestGit" < "$FILE" > /dev/null
    then
        FOUND=1
    else
        fail "No withLatestGit found in '$FILE'"
    fi
done < <(find ~/.nixpkgs -name "warbo-utilities.nix")

[[ "$FOUND" -eq 1 ]] || fail "Couldn't find warbo-utilities.nix"

echo "OK, we can use warbo-utilities to test withLatestGit"

echo "Checking if nix_git_rev_... is set inside nix-shell"
OUTPUT=$(nix-shell --show-trace -p warbo-utilities --run \
         'env | grep nix_git_rev')

echo "$OUTPUT" | grep "^nix_git_rev_" > /dev/null ||
    fail "No nix_git_rev_... variables were set: $OUTPUT"

echo "Shell environment contained nix_git_rev_... variable"

echo "Running nested nix-shells"
OUTPUT=$(nix-shell --show-trace -p warbo-utilities --run \
        'nix-shell --show-trace -p warbo-utilities --run true' 2>&1)
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
*/
