args:

with { pkgs = import ./helpers/nix-config.nix args; };
with pkgs;
withDeps (allDrvsIn (callPackage ./tests.nix args))
         (runCommand "tests" {} ''echo "pass" > "$out"'')
