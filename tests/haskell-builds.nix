#! /usr/bin/env nix-shell
#! nix-shell -i bash -p haskellPackages.cabal-install

shopt -s nullglob

function cached {
    ./helpers/cache.sh "haskell-builds" < <(./helpers/my_haskell.sh)
}

function report {
    if [[ "$1" -eq 0 ]]
    then
        echo "ok - $2"
        return
    else
        echo "not ok - $2"
        return 1
    fi
}

function cabalBuild {
    for PKGS in "" #"(import <nixpkgs> {}).stable"
    do
        for COMPILER in "" #ghc7102 ghc7103 ghc783 ghc784 ghc801
        do
            export PKGS
            export COMPILER
            echo "Configuring with PKGS='$PKGS', COMPILER='$COMPILER'" 1>&2

            /home/chris/warbo-utilities/development/hsConfig
            report "$?" "Configured with PKGS='$PKGS', COMPILER='$COMPILER'" ||
                exit 1

            echo "Configured, building" 1>&2
            cabal build
            report "$?" "Built with PKGS='$PKGS', COMPILER='$COMPILER'" ||
                exit 1

            echo "Built" 1>&2
        done
    done
}

function buildFiles {
    shopt -s nullglob
    ERR=0
    for HS in *.hs *.lhs
    do
        echo "Type-checking '$HS'"
        if ! nix-shell -p haskellPackages.ghc --run "ghc '$HS' -e 'return ()'"
        then
            ERR=1
        fi
    done
    exit "$ERR"
}

cached > /dev/null

# Check how we were called
if NAME=$(./helpers/getName.sh "$0")
then
    LINES=$(./helpers/checkNames.sh "$NAME" < <(cached)) || ERR=1
    while read -r DIR
    do
        cd "$DIR" || { echo "Couldn't cd to '$DIR'" 1>&2; exit 1; }
        if test -n "$(find . -maxdepth 1 -type f -name '*.cabal' -print -quit)"
        then
            echo "Found Cabal file in '$DIR', trying to configure and build project"
            cabalBuild
        else
            echo "No Cabal file in '$DIR', type-checking any individual files"
            buildFiles
        fi
    done < <(echo "$LINES")
else
    ./helpers/namesMatch.sh "haskell-builds" < <(cached) || exit 1
fi
