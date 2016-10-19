with import <nixpkgs> {};
with lib;
with builtins;

with rec {

  pathSafe = replaceStrings ["/"] ["_"];

  defs     = mapAttrs (n: _: import (./tests + "/${n}"))
                      (readDir ./tests);

  tests    = listToAttrs
               (concatMap (def: map (test: rec {
                                      name  = pathSafe "${def}.${test}";
                                      value = rec {
                                        script = defs."${def}"."${test}";
                                        pass   = (readDir ./results/pass) ? name;
                                        drv    = script.drvPath;
                                      };
                                    })
                                    (attrNames defs."${def}"))
                          (attrNames defs));

};

tests
