{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

ERR=0
HANDLED=0
UNHANDLED=0
BIB=~/Writing/Bibtex.bib
DATA=$(grep "localfile" < "$BIB")

for F in ~/Documents/* ~/Documents/ArchivedPapers/*
do
    [[ -f "$F" ]] || continue

    NAME=$(basename "$F")
    MSG="Found '$NAME' in '$BIB'"

    if echo "$DATA" | grep -F "$NAME" > /dev/null
    then
        echo "ok - $MSG"
        HANDLED=$(( HANDLED + 1 ))
    else
        echo "not ok - $MSG"
        UNHANDLED=$(( UNHANDLED + 1 ))
    fi
done

MSG="All documents are in '$BIB'"
if [[ "$UNHANDLED" -eq 0 ]]
then
    echo "ok - $MSG"
else
    echo "not ok - $MSG"
fi

# Ensure we don't get any worse
FRACTION=$(( (UNHANDLED * 100) / (UNHANDLED + HANDLED) ))

ALLOWED=27

MSG="Unhandled documents ($FRACTION %) at acceptable limit ($ALLOWED %)"
if [[ "$FRACTION" -gt "$ALLOWED" ]]
then
    echo "not ok - $MSG"
else
    echo "ok - $MSG"
fi

exit "$ERR"
*/
