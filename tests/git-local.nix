{ helpers, pkgs }:
helpers.notImplemented "git-local"

        /*
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash xidel

function repos {
    xidel -q "http://chriswarbo.net/git" --extract "//td/a/@href"
}

function data {
    while read -r DIR
    do
        # Strip trailing /
        NAME=$(echo "$DIR" | rev | cut -c 2- | rev)

        # Ignore non-.git
        EXT=$(echo "$NAME" | rev | cut -c 1-4 | rev)

        [[ "x$EXT" = "x.git" ]] && echo "$NAME"
    done < <(repos)
}

function cached {
    ./helpers/cache.sh "git-local" < <(data)
}

cached > /dev/null

ERR=0
while read -r REPO
do
    # Make sure we have a local copy of the repo
    LOCAL="/home/chris/Programming/repos/$REPO"
    [[ -e "$LOCAL" ]] || {
        ERR=1
        echo "Could not find '$LOCAL'" 1>&2
        continue
    }

    # Make sure our local copy has its remote set
    REMOTE="chris@chriswarbo.net:/opt/repos/$REPO"
    pushd "$LOCAL" > /dev/null
      grep "url = $REMOTE" < config > /dev/null || {
        ERR=1
        echo "Repo '$LOCAL' doesn't have remote '$REMOTE'" 1>&2
      }
    popd > /dev/null
done < <(cached)

exit "$ERR"
*/
