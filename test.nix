with import <nixpkgs> {};
with lib;
with builtins;

now: rec {

args = pkgs // { inherit scriptTest testMsg; };

testMsg = msg: dbg: x:
            let info = toJSON { inherit dbg msg; };
                m    = if x then "ok - ${msg}"
                            else "not ok - ${msg}\n${info}";
             in addErrorContext info (trace m true);

scriptTest = msg: { env ? {}, script }:
               let file   = writeScript "script-test" script;
                   result = fromJSON (runScript env ''
                     if ${file} 1> stdout 2> stderr
                     then
                       RESULT=true
                     else
                       RESULT=false
                     fi

                     STDOUT=$(nix-store --add stdout)
                     STDERR=$(nix-store --add stderr)

                     printf '{"result":%s, "stdout":"%s", "stderr":"%s"}' \
                            "$RESULT" "$STDOUT" "$STDERR" > "$out"
                   '');
                in testMsg msg result result.result;

allSuccess = all (x: import (./tests + "/${x}") args now)
                 (filter (hasSuffix ".nix")
                         (attrNames (readDir ./tests)));

}.allSuccess
