{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

function files {
    # Find .git/config files
    locate -e "/home/chris/ * /config" |
        grep    ".git"               |
        grep -v "/git-html"
}

function cached {
    ./helpers/cache.sh "git-sourced" < <(files)
}

function getUrls {
    while read -r CONF
    do
        [[ -z "$CONF" ]] && continue

        # Find URLs mentioned in .git/config files
        while read -r REMOTE
        do
            echo "$CONF	$REMOTE"
        done < <(grep "^\s*url\s*=" < "$CONF")
    done < <(echo "$CACHED")
}

function remotesExist {
    while read -r LINE
    do
        [[ -z "$LINE" ]] && continue
        CONF=$(echo "$LINE" | cut -f 1)
        URL=$(echo  "$LINE" | cut -f 2 | cut -d '=' -f 2 | sed -e 's@^\s*@@')
        if echo "$URL" | grep ':' > /dev/null
        then
            echo "Found remote '$URL'"

            # gitorious.org is no more
            echo "$URL" | grep "gitorious" > /dev/null && {
                ERR=1
                echo "Reference to gitorious found in '$CONF'" 1>&2
            }
        else
            echo "Found local '$URL'"
            [[ -e "$URL" ]] || {
                ERR=1
                echo "Remote '$URL' doesn't exist in '$CONF'" 1>&2
            }
        fi
    done < <(getUrls)
}

function localsExist {
    # Check that repos/foo.git is a remote of some local repo
    shopt -s nullglob
    URLS=$(getUrls)
    for REPO in /home/chris/Programming/repos/*.git
    do
        echo "Looking for a source of '$REPO'"
        echo "$URLS" | cut -f 2 | grep "$REPO" > /dev/null || {
            echo "No source found for '$REPO'" 1>&2
            ERR=1
        }
    done
}

CACHED=$(cached)
ERR=0

remotesExist
 localsExist

exit "$ERR"
*/
