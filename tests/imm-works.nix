{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

OUTPUT=$(nix-shell -p 'haskellPackages.imm' --run "imm -u" 2>&1) ||
    fail "imm aborted: $OUTPUT"

if echo "$OUTPUT" | grep "Recompiling." > /dev/null
then
    echo "$OUTPUT" | grep "Program reconfiguration successful." > /dev/null ||
        fail "Looks like recompiling imm config failed: $OUTPUT"
fi
*/
