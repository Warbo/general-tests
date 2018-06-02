{ nix-config ? null, nixpkgs ? null, packageOnly ? true }:

with builtins;
with {
  pkgs = import ./helpers/nix-config.nix { inherit nix-config nixpkgs; };
};
with pkgs;
with lib;
with rec {
  helpers = callPackage ./helpers {};

  tests   = import ./tests { inherit helpers pkgs; };

  all = wrap {
    name   = "test-runner";
    paths  = [ bash jq ];
    vars   = { tests = attrsToDirs tests; };
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
        printf 'Running %s...' "$T"
        if "$T" 1> /dev/null 2> /dev/null
        then
          SUCCESS=$(( SUCCESS + 1 ))
          echo "PASS"
        else
          FAIL=$(( FAIL + 1 ))
          echo "FAIL"
        fi
      done

      if [[ "$FAIL" -eq 0 ]]
      then
        echo "<fc=#00FF00>$SUCCESS/$COUNT</fc>" > /tmp/test_results
        echo "$SUCCESS/$COUNT Test suite finished successfully" 1>&2
        exit 0
      else
        echo "<fc=#FF0000>$SUCCESS/$COUNT</fc>" > /tmp/test_results
        echo "$SUCCESS/$COUNT Test suite encountered failures" 1>&2
        exit "$FAIL"
      fi
    '';
  };
};
if packageOnly
   then all
   else { inherit all helpers tests; }
