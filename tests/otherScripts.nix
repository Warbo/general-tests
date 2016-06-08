pkgs:

with pkgs;
with lib;
with builtins;

rec {

run = s: fromJSON (runScript {
                     NIX_REMOTE  = "daemon";
                     NIX_PATH    = getEnv "NIX_PATH";
                     buildInputs = [ nix ];
                   } s);

# Add ../scripts/${f} to the store. We read and write the contents, so that
# hashes are updated when files change, and hence tests are re-run.
inStore   = f: toFile "test-script-${f}"
                      (readFile "${toString ../scripts}/${f}");

# An array mapping script names to paths in the Nix store
scripts = fold (f: rest: rest // listToAttrs [{
                                   name  = f;
                                   value = inStore f;
                                 }])
               {}
               (filter (n: n != "testsUsingNix")
                       (attrNames (readDir ../scripts)));

scriptResult = f: fromJSON (runScript {} ''
                    if "${toString ../scripts}"/"${f}" 1> stdout 2> stderr
                    then
                      RESULT=true
                    else
                      RESULT=false
                    fi

                    STDOUT=$(nix-store --add stdout)
                    STDERR=$(nix-store --add stderr)

                    printf '{"result": %s, "info": {"stdout": "%s", "stderr": "%s"}}' \
                           "$RESULT" "$STDOUT" "$STDERR" > "$out"
                  '');

resultsOf = n: { name = n; value = scriptResult n; };

results = listToAttrs (map resultsOf (attrNames scripts));

}
