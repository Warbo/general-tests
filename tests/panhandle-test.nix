{ helpers, pkgs }:

with pkgs;
runCommand "panhandle-test"
  (withNix {
    buildInputs = [ cabal2nix fail haskellPackages.cabal-install pandoc ];
    dir         = helpers.inputFallback "panhandle";
    nixConfig   = helpers.inputFallback "nix-config";
  })
  ''
    export HOME="$PWD"
    ln -s "$nixConfig" "$HOME/.nixpkgs"

    cd "$dir"
    ./test.sh
    echo "pass" > "$out"
  ''
