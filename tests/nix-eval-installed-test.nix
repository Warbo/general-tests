{ helpers, pkgs }:
helpers.notImplemented "nix-eval-installed"

/*
#!/usr/bin/env bash

# Test that we can use an installed nix-eval, i.e. from outside its source
# directory

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

function prog {
    cat <<'EOF'
import Language.Eval
import Data.Maybe
main = do x <- eval (raw "show" $$ raw "True")
          case x of
               Just y  -> putStr y
               Nothing -> error "Failed"
EOF
}

function runProg {
    prog | nix-shell -p 'haskellPackages.ghcWithPackages (h: [ h.nix-eval ])' \
                     --run runhaskell ||
        fail "Failed to use nix-eval"
}

OUTPUT=$(runProg)

[[ "x$OUTPUT" = "xTrue" ]] || fail "Wrong output '$OUTPUT'"
*/
