{ helpers ? pkgs.callPackage ../helpers {}, pkgs ? import <nixpkgs> {} }:

with builtins;
with pkgs.lib;
listToAttrs (map (f: {
                   name  = removeSuffix ".nix" f;
                   value = import (./. + "/${f}") {
                     inherit helpers pkgs;
                   };
                 })
                 (filter (n: n != "default.nix")
                         (attrNames (readDir ./.))))
