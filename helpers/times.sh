#!/usr/bin/env bash

grep -ro "[^ ]*elapsed" results/time           |
sed -e 's/^\([^:]*\):\([^e]*\)elapsed/\2 \1/g' |
sed -e 's@results/time/@scripts/@g'            |
sort                                           |
while read -r LINE
do
    SCRIPT=$(echo "$LINE" | cut -d ' ' -f2)
    NAME=$(basename "$SCRIPT")
    if [[ -e "$SCRIPT" ]]
    then
        echo "$LINE"
    else
        echo "Deleting time for non-existent '$SCRIPT'" >> /dev/stderr
        rm "results/time/$NAME"
    fi
done
