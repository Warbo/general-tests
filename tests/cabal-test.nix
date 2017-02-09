{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash gnused haskellPackages jq runCommand sanitiseName stdenv;
  inherit (helpers)
    allHaskell combineTests compileHaskell haskellRepos repoOf;
};
with rec {

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
