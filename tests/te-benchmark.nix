#!/usr/bin/env bash
set -e

cd ~/Programming/TheoryExplorationBenchmark

nix-shell --run "raco test defs.rkt"
