#!/usr/bin/env bash
shopt -s nullglob

function mktest {
    echo "Making test for '$1'"
    NAME="custom-pkg.$1"
    pushd scripts > /dev/null    &&
    ln -s custom-pkgs "$NAME"    &&
    popd > /dev/null             &&
    touch "results/stderr/$NAME" &&
    touch "results/stdout/$NAME"
}

function packageNames {
    BASE=~/.nixpkgs/custom
    # "Local" is where we keep "regular" packages
    for FILE in "$BASE"/local/*.nix
    do
        basename "$FILE" .nix
    done

    # "Imports" are usually special-cases
    for FILE in "$BASE"/imports/*.nix
    do
        basename "$FILE" .nix
    done

    # Haskell packages need prefixing by the compiler version
    for FILE in "$BASE"/haskell/*.nix
    do
        NAME=$(basename "$FILE" .nix)
        echo "haskellPackages.$NAME"
    done

    # One offs (usually overrides)
    echo get_iplayer
}

function mkExpr {
    # Since Nix is lazy, knowing that an expression exists doesn't tell us much;
    # we must try to build it, in order to expose problems.
    # We face two difficulties: not everything is a package, and those which are
    # need to be forced. If something's not a package, we return `bash` as a
    # fallback. To prevent headaches, these nested `if` expressions are
    # structured like a `case`, i.e.
    # if foo then A
    #        else if bar then B
    #                    else if baz then C
    #                                else D

    # Packages are attribute sets, so we restrict ourselves to those (ignoring,
    # e.g. helper functions and things)
    echo "if builtins.typeOf ($1) != \"set\" then bash else"

    # If we have a set, we want to determine if it's a package. If it has
    # "executable", then it's probably a script rather than a package:
    echo "if ($1) ? executable && ($1).executable then bash else"

    # If something contains a "src", it's probably a package:
    echo "if ($1) ? src then ($1) else"

    # If something contains a "buildCommand", it may be a package:
    echo "if ($1) ? buildCommand then ($1)"

    # Fall back to bash
    echo "else bash"
}

function checkPkg {
    EXPR=$(mkExpr "$1")
    nix-shell --show-trace --run true -p "$EXPR" || {
        echo "Couldn't invoke nix-shell for '$1' (NIX_LOCAL_ONLY=$NIX_LOCAL_ONLY)" 1>&2
        exit 1
    }
}

# Get the package to test from our invocation name
PKG=$(basename "$0" | cut -c 12-)

ERR=0
if [[ -z "$PKG" ]]
then
    # No package given, make sure we have all of them

    # All custom Nix expressions should have a test
    while read -r PKG
    do
        echo "Checking we have a test for '$PKG'"
        [[ -e "scripts/custom-pkg.$PKG" ]] || {
            echo "'$PKG' doesn't have a test" 1>&2
            mktest "$PKG" || ERR=1
        }
    done < <(packageNames)

    # All tests must correspond to a Nix expression
    for SCRIPT in scripts/custom-pkg.*
    do
        echo "Checking there is a Nix expression for '$SCRIPT'"
        PKG=$(basename "$SCRIPT" | cut -c 12-)
        FOUND=$(nix-instantiate  \
                    --show-trace \
                    --eval       \
                    --expr "let pkgs = import <nixpkgs> {}; in pkgs ? $PKG")
        [[ "x$FOUND" = "xtrue" ]] || {
            echo "'$PKG' doesn't seem to be a package" 1>&2
            ERR=1
        }
    done
    exit "$ERR"
else
    # Got a package, try to build it
    NIX_LOCAL_ONLY=0 checkPkg "$PKG"
    NIX_LOCAL_ONLY=1 checkPkg "$PKG"
fi
