{ pkgs }:

with builtins;
with pkgs.lib;
with rec { helpers = pkgs.callPackage ./helpers {}; };

listToAttrs (map (f: {
                   name  = removeSuffix ".nix" f;
                   value = import (./tests + "/${f}") { inherit helpers pkgs; };
                 })
                 (attrNames (readDir ./tests)))
