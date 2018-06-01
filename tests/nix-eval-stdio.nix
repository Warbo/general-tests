{ helpers, pkgs }:
helpers.notImplemented "nix-eval-stdio"

/*
#!/usr/bin/env bash

function fail {
    echo -e "FAIL: $1" 1>&2
    exit 1
}

function tryNixEval {
    CODE=$(codeNixEval)
    echo -e "RUNNING:\n\n$CODE\n\n---\n" 1>&2
    echo "$CODE" | nix-shell -p 'haskellPackages.ghcWithPackages (h: [ h.nix-eval ])' --run runhaskell
}

function codeNixEval {
  cat <<'EOF'
import Language.Eval

main = do Just x <- eval (raw "show" $$ ((raw "(&&)" $$ raw "True") $$ raw "True"))
          putStrLn x
EOF
}

function testNixEval {
    RESULT=$(tryNixEval)

    [[ "x$RESULT" = "xTrue" ]] || fail "Wrong value"

    echo "testNixEval passed" 1>&2
}

function tryMLSpec {
    CODE=$(codeMLSpec)
    echo -e "RUNNING:\n\n$CODE\n\n---\n" 1>&2

    echo "$CODE" | nix-shell -p 'haskellPackages.ghcWithPackages (h: [ h.mlspec h.nix-eval ])' --run runhaskell ||
        fail "Attempting to evaluate MLSpec-using code aborted"
}

function codeMLSpec {
    cat <<'EOF'
import Language.Eval
import MLSpec.Theory
main = do Just x <- runTheory (T [
            --  E (raw "not",   Ty "Bool -> Bool",         A 1)
            --, E (raw "True",  Ty "Bool",                 A 0)
            --, E (raw "False", Ty "Bool",                 A 0)
            --  E (raw "||",    Ty "Bool -> Bool -> Bool", A 2)
              E (raw "+", Ty "Int -> Int -> Int", A 2)
            , E (raw "*", Ty "Int -> Int -> Int", A 2)
            --, E (raw "&&",    Ty "Bool -> Bool -> Bool", A 2)
            ])
          putStrLn x
EOF
}

function testMLSpec {
    RESULT=$(tryMLSpec)
    JSON=$(echo "$RESULT" | grep -v "^Depth")
    ALL_LINES=$(echo "$JSON" | wc -l)
    JSON_LINES=$(echo "$JSON" | grep -c "^{")

    [[ "$ALL_LINES" -eq "$JSON_LINES" ]] ||
        fail "Only $JSON_LINES/$ALL_LINES look like JSON:\n$RESULT"

    echo "testMLSpec passed" 1>&2
}

echo "Running tests with debug"

NIX_EVAL_DEBUG=1 testNixEval
NIX_EVAL_DEBUG=1 testMLSpec

echo "Running tests without debug"

testNixEval
testMLSpec
*/
