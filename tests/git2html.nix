        { helpers, pkgs }:
        with pkgs;
        runCommand "dummy" {} "exit 1"

        /*
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash which git2html
which git2html && echo "git2html script is installed"
*/
