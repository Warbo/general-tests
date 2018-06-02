#!/usr/bin/env bash

# List as many shell scripts as possible, which are in my control to edit

function isSh {
    [[ "x$(ext "$1")" = "xsh" ]]
}

function hasShebang {
    grep '^#!' < "$1" > /dev/null
}

function isBinary {
    grep "^#!" < "$1" | grep "^Binary file" > /dev/null
}

function hasLowercase {
    # Skip LICENSE, README, etc.
    basename "$1" | grep -- "[a-z]" > /dev/null
}

function isHidden {
    [[ "x$(basename "$1" | cut -c 1)" = "x." ]]
}

function nonShellInterpreter {
    # Skip non-bash interpreters
    CONTENT=$(grep "^#!" < "$1")
    for NOPE in python haskell make
    do
        # /usr/bin/env lines
        echo "$CONTENT" | grep -- "/usr/bin.*$NOPE" > /dev/null && return 0
        # nix-shell interpreters
        echo "$CONTENT" | grep -- "-i $NOPE"        > /dev/null && return 0
    done
    return 1
}

function scriptFile {
    file "$1" | grep -e 'POSIX shell script' \
                     -e 'Bourne-Again shell script' > /dev/null
}

function readPermission {
    [[ -r "$1" ]]
}

function keep {
    readPermission      "$1" || return 1
    isSh                "$1" && return 0
    scriptFile          "$1" && return 0
    hasShebang          "$1" || return 1
    isBinary            "$1" && return 1
    hasLowercase        "$1" || return 1
    isHidden            "$1" && return 1
    nonShellInterpreter "$1" && return 1
    return 0
}

function skipExt {
    grep -v "\.${1}$"
}

function skip {
    grep -v -e '/\.git'                                   \
            -e '/\.svn'                                   \
            -e '/NotMine/'                                \
            -e 'Tests/results/'                           \
            -e '/test-data/'                              \
            -e '/git-html'                                \
            -e '/Programming/repos/'                      \
            -e '/haskell-te/cache/'                       \
            -e '\.nix$'                                   \
            -e '\.lyx$'                                   \
            -e '\.agda.*$'                                \
            -e '\.hs$'                                    \
            -e '\.png$'                                   \
            -e '\.html$'                                  \
            -e '\.c$'                                     \
            -e '\.o$'                                     \
            -e '\.h$'                                     \
            -e '\.cpp$'                                   \
            -e '\.py.*$'                                  \
            -e '\.deb$'                                   \
            -e '\.gz$'                                    \
            -e '\.txt$'                                   \
            -e '\.v.*$'                                   \
            -e '\.lhs$'                                   \
            -e '\.rb$'                                    \
            -e '\.ps$'                                    \
            -e '\.php$'                                   \
            -e '\.pl$'                                    \
            -e '\.md$'                                    \
            -e '\.conf$'
}

function ext {
    echo "$1" | rev | cut -d '.' -f 1 | rev | tr '[:upper:]' '[:lower:]'
}

for D in System/Tests System/Programs/bin blog warbo-utilities Programming \
         Writing
do
    D="$HOME/$D"
    if [[ -d "$D" ]]
    then
        echo "Looking for shell scripts in '$D'" 1>&2
        "$findIgnoringPermissions" "$D" -type f           \
                                      ! -path '*.git*'    \
                                      ! -path '*.svn*'    \
                                      ! -path '*.issues*' | skip |
        while read -r LINE
        do
            keep "$LINE" && echo "$LINE"
        done
    else
        echo "Skipping non-existent directory '$D'" 1>&2
    fi
done
exit 0
