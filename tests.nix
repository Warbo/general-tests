{ pkgs ? import <nixpkgs> {} }:
with builtins;

with rec {
  inherit (pkgs)
    latestGit lib stdenv;

  # Use this for helper functions, etc. common to many tests
  helpers = rec {
    getGit = url: latestGit { inherit url; };

    repoOf = r: "http://chriswarbo.net/git/${r}.git";

    haskellRepos = map repoOf allHaskell;

    haskellSources = map getGit haskellRepos;

    allHaskell = myHaskell ++ notMyHaskell;

    myHaskell = [
      "arbitrary-haskell" "ast-plugin" "get-deps" "hs2ast-tests" "hs2ast"
      "k-means" "lazy-lambda-calculus" "ml4hs-helper" "ml4hsfe" "mlspec-bench"
      "mlspec-helper" "mlspec" "nix-eval" "order-deps" "panhandle" "panpipe"
      "quickspec-measure" "reduce-equations" "runtime-arbitrary-tests"
      "sample-bench" "tree-features" "type-parser"
    ];

    notMyHaskell = [
      "hipspec" "ifcxt" "lazy-smallcheck-2012" "quickspec"
    ];

    combineTests = name: tests:
      tests // {
        test = stdenv.mkDerivation {
          inherit name;
          buildInputs  = attrValues tests;
          buildCommand = ''
            echo "Pass" > "$out"
          '';
        };
      };
  };
};
with lib;
mapAttrs (n: _: import (./tests + "/${n}") { inherit helpers pkgs; })
         (readDir ./tests)
