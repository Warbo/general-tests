with import <nixpkgs> {};
with lib;
with builtins;

rec {

args = pkgs // { inherit scriptTest; };

getTest = x: old: old // listToAttrs [{
                           name  = x;
                           value = import (./tests + "/${x}") args;
                         }];
tests   = fold getTest
               {}
               (filter (hasSuffix ".nix")
                       (attrNames (readDir ./tests)));

scriptTest = { env ? {}, script }: fromJSON (runScript env ''
               if ${writeScript "script-test" script} 1> stdout 2> stderr
               then
                 RESULT=true
               else
                 RESULT=false
               fi

               STDOUT=$(nix-store --add stdout)
               STDERR=$(nix-store --add stderr)

               printf '{"result":%s, "info":{"stdout":"%s", "stderr":"%s"}}' \
                      "$RESULT" "$STDOUT" "$STDERR" > "$out"
             '');

results = fold (x: rest: rest // tests."${x}".results) {} (attrNames tests);

allSuccess = all (n: results."${n}".result)
                 (attrNames results);

}
