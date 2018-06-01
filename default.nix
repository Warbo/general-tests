{ nix-config ? null, nixpkgs ? null, packageOnly ? true }:

with rec {
  pkgs  = import ./helpers/nix-config.nix { inherit nix-config nixpkgs; };
  tests = import ./tests.nix              { inherit pkgs; };
  all   =
    with builtins; with pkgs;
    wrap {
      name   = "test-runner";
      paths  = [ bash jq ];
      vars   = {
        tests = attrsToDirs (listToAttrs (map (d: {
                                                inherit (d) name;
                                                value = d;
                                              })
                                              (allDrvsIn tests)));
      };
      script = ''
        #!/usr/bin/env bash
        set -e
        shopt -s nullglob

        COUNT=0
        SUCCESS=0
        FAIL=0
        for T in "$tests"/*
        do
          COUNT=$(( COUNT + 1 ))
          NAME=$(basename "$T")
          if "$T" 1> /dev/null 2> /dev/null
          then
            SUCCESS=$(( SUCCESS + 1 ))
            echo "ok - $T"
          else
            FAIL=$(( FAIL + 1 ))
            echo "not ok - $T"
          fi
        done

        if [[ "$FAIL" -eq 0 ]]
        then
          echo "<fc=#ff0000>$SUCCESS/$COUNT</fc>" > /tmp/test_results
          echo "$SUCCESS/$COUNT Test suite finished successfully" 1>&2
          exit 0
        else
          echo "<fc=#00FF00>$SUCCESS/$COUNT</fc>" > /tmp/test_results
          echo "$SUCCESS/$COUNT Test suite encountered failures" 1>&2
          exit "$FAIL"
        fi
      '';
    };
};
if packageOnly
   then all
   else { inherit all pkgs tests; }
