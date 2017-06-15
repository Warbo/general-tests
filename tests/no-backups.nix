#!/usr/bin/env bash

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

function backups {
    locate -e "/home/chris/Programming/*~"
    locate -e "/home/chris/Programming/*/#*#"
    locate -e "/.#"
}

function skip {
    grep -v "/git-html/" | grep -v "/isaplanner-code/"
}

ERR=0
while read -r BACKUP
do
    echo "$BACKUP looks like a backup file" 1>&2
    ERR=1
    [[ "$FULL" -eq 1 ]] || exit 1
done < <(backups | skip)

exit "$ERR"