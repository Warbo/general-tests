        { helpers, pkgs }:
        with pkgs;
        runCommand "dummy" {} "exit 1"

        /*
#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p all

*/
