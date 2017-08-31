{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with rec {
  inherit (pkgs)
    bash gnused haskellPackages jq lib runCommand sanitiseName stdenv;

  inherit (lib)
    mapAttrs;

  inherit (helpers)
    allHaskell compileHaskell haskellRepos repoOf;

  testRepo = name: repo:
    stdenv.mkDerivation {
      name         = "cabal-test";
      buildInputs  = [ (compileHaskell name repo "test") ];
      buildCommand = ''
        echo "Passed" > "$out"
      '';
    };

  tests = mapAttrs testRepo allHaskell;
};

tests
