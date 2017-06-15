{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash
set -e
cd /home/chris/Programming/Haskell/ML4HSFE
./test.sh
*/
