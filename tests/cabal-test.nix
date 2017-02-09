{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash /*findutils*/ gnused haskellPackages jq runCommand
    sanitiseName stdenv;
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

tests = listToAttrs (map (name: {
                           inherit name;
                           value = testRepo (repoOf name);
                         })
                         allHaskell);
};

combineTests "cabal-tests" tests
