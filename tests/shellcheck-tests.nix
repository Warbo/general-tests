{ helpers, pkgs }:
with pkgs;
with rec {
  REAL_HOME = "/home/chris";
};
runCommand "dummy"
  {
    inherit REAL_HOME;
    buildInputs = [ shellcheck warbo-utilities ];
  }
  ''
    #!/usr/bin/env bash

    shopt -s nullglob

    if [[ -e "$REAL_HOME" ]]
    then
      export HOME="$REAL_HOME"
    fi

    function skip {
      grep -v "\.rkt$"                |
      grep -v "/haskell-te/packages/" |
      grep -v "/TheoryExplorationBenchmark/modules/" | while read -r F
      do
        if head -n1 < "$F" | grep    "nix-shell"     > /dev/null &&
           head -n2 < "$F" | grep -- "-i runhaskell" > /dev/null
        then
          # Skip Haskell file
          continue
        fi
        if head -n1 < "$F" | grep "racket" > /dev/null
        then
          # Skip Racket file
          continue
        fi
        echo "$F"
      done
    }

    ERR=0
    while read -r script
    do
      [[ -f "$script" ]] || continue
      echo "Checking '$script'" 1>&2
      if shellcheck -e SC1091 -e SC1008 -e SC2001 -e SC2029 "$script"
      then
        echo "Passed: '$script'" 1>&2
      else
        echo "Failed: '$script'" 1>&2
        ERR=1
      fi
    done < <(my_shellscripts | skip)

    if [[ "$ERR" -eq 0 ]]
    then
      echo "pass" > "$out"
    fi

    exit "$ERR"
  ''
