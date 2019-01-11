{ nix-config ? null, nixpkgs ? null, packageOnly ? true }:

with builtins;
with {
  pkgs = import ./helpers/nix-config.nix { inherit nix-config nixpkgs; };
};
with pkgs;
with lib;
with rec {
  helpers = callPackage ./helpers {};

  individualDir = "/tmp/test_results.individual";

  tests   = import ./tests { inherit helpers pkgs; };

  # Flatten the test hierarchy and have each one write to its result file
  testScripts = attrsToDirs
    (mapAttrs (name: script: wrap {
                name   = name + "-runner";
                vars   = {
                  inherit individualDir script;
                  fileName = name;
                };
                script = ''
                  #!/usr/bin/env bash
                  mkdir -p "$individualDir"
                  if "$script"
                  then
                    echo "PASS" > "$individualDir/$fileName"
                    exit 0
                  else
                    echo "FAIL" > "$individualDir/$fileName"
                    exit 1
                  fi
                '';
              })
              (helpers.flattenToPaths tests));

  all = wrap {
    name   = "test-runner";
    paths  = [ bash jq ];
    vars   = {
      inherit individualDir;
      tests     = testScripts;
      countFile = "/tmp/test_results";
    };
    script = ''
      #!/usr/bin/env bash
      set -e
      shopt -s nullglob

      # Make sure $individualDir contains only files corresponding to $tests/*
      mkdir -p "$individualDir"
      for F in "$individualDir"/*
      do
        NAME=$(basename "$F")
        [[ -e "$tests/$NAME" ]] || rm -f "$F"
      done

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
        echo "<fc=#00FF00>$SUCCESS/$COUNT</fc>" > "$countFile"
        echo "$SUCCESS/$COUNT Test suite finished successfully" 1>&2
        exit 0
      else
        echo "<fc=#FF0000>$SUCCESS/$COUNT</fc>" > "$countFile"
        echo "$SUCCESS/$COUNT Test suite encountered failures" 1>&2
        exit "$FAIL"
      fi
    '';
  };
};
if packageOnly
   then all
   else { inherit all helpers tests; }
