{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash
set -e

cd ~/Programming/TheoryExplorationBenchmark

nix-shell --run "raco test defs.rkt"
*/
