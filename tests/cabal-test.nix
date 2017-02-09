{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with rec {
  inherit (pkgs)
    bash gnused haskellPackages jq lib runCommand sanitiseName stdenv;

  inherit (lib)
    mapAttrs;

  inherit (helpers)
    allHaskell combineTests compileHaskell haskellRepos repoOf;

  testRepo = repo:
    stdenv.mkDerivation {
      name         = "cabal-test";
      buildInputs  = [ (compileHaskell repo "test") ];
      buildCommand = ''
        echo "Passed" > "$out"
      '';
    };

  tests = mapAttrs (_: testRepo) allHaskell;
};

combineTests "cabal-tests" tests
