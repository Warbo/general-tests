{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash
~/.emacs.d/tests/run.sh
*/
