with import <nixpkgs> {};
with lib;
with builtins;

rec {

getTest = x: old: old // listToAttrs [{
                           name  = x;
                           value = import (./tests + "/${x}") pkgs;
                         }];
tests   = fold getTest
               {}
               (filter (hasSuffix ".nix")
                       (attrNames (readDir ./tests)));

results = fold (x: rest: rest // tests."${x}".results) {} (attrNames tests);

allSuccess = all (n: results."${n}".result)
                 (attrNames results);

}
