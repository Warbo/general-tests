with import <nixpkgs> {};
with lib;
with builtins;

with rec {

  pathSafe = replaceStrings ["/"] ["_"];

  tests   = mapAttrs (n: _: import (./tests + "/${n}"))
                     (readDir ./tests);

  scripts = listToAttrs
              (concatMap (test: map (script: rec {
                                      name  = pathSafe "${test}.${script}";
                                      value = {
                                        script = tests."${test}"."${script}";
                                        pass   = (readDir ./results/pass) ? name;
                                      };
                                    })
                                (attrNames tests."${test}"))
                         (attrNames tests));

};

scripts
