with import <nixpkgs> {};

writeScript "hlint" ''
  #!/usr/bin/env bash

  shopt -s nullglob

  # Pass in the argument "full" to keep going after a failure
  FULL=0
  [[ "x$1" = "xfull" ]] && FULL=1

  # Run hlint on (almost) everything in ~/Programming/Haskell

  function hs {
    my_haskell
    for FILE in ~/Programming/Haskell/*.hs ~/Programming/Haskell/*.lhs
    do
      echo "$FILE"
    done
  }

  function skip {
    grep -v "/Haskell/quickcheck$" |
    grep -v "/Haskell/imm$"        |
    grep -v "/Haskell/ifcxt$"
  }

  function data {
    hs | skip
  }

  function cached {
    ./helpers/cache.sh "hlint" < <(data)
  }

  cached > /dev/null

  ERR=0
  if NAME=$(./helpers/getName.sh "$0")
  then
    LINES=$(./helpers/checkNames.sh "$NAME" < <(cached)) || ERR=1
    while IFS= read -r HASKELL
    do
      echo "Processing '$HASKELL'"
      if ! hlint -XNoCPP "--ignore=Parse error" "$HASKELL"
      then
        ERR=1
        [[ "$FULL" -eq 1 ]] || exit 1
      fi
    done < <(echo "$LINES")
  else
    ./helpers/namesMatch.sh "hlint" < <(cached) || exit 1
  fi

  exit "$ERR"
''
