{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

# Pass in the argument "full" to keep going after a failure
FULL=0
[[ "x$1" = "xfull" ]] && FULL=1

function scripts {
    find ~/System/Tests    -name "*.sh"
    find ~/warbo-utilities -name "*.sh"
}

ERR=0
while read -r script
do
    SHEBANG=$(head -n 1 < "$script")
    if echo "$SHEBANG" | grep "#![ ]*/bin/sh" > /dev/null
    then
        echo "#!/bin/sh in $script may break on Debian (dash)" 1>&2
        ERR=1
    fi
    if echo "$SHEBANG" | grep "#![ ]*/bin/bash" > /dev/null
    then
        echo "#!/bin/bash in $script won't work on NixOS" 1>&2
        ERR=1
    fi
    if echo "$SHEBANG" | grep "#![ ]*/usr/bin" > /dev/null &&
     ! echo "$SHEBANG" | grep "/usr/bin/env" > /dev/null
    then
        echo "Shebang for $script may not work on NixOS"
        ERR=1
    fi
    [[ "$ERR" -eq 0 ]] || [[ "$FULL" -eq 1 ]] || exit 1
done < <(scripts)

exit "$ERR"
*/
