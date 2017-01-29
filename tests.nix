{ pkgs ? import <nixpkgs> {} }:
with builtins;

with rec {
  inherit (pkgs)
    latestGit lib;

  # Use this for helper functions, etc. common to many tests
  helpers = rec {
    haskellRepos = map (r: "http://chriswarbo.net/git/${r}.git") [
      "arbitrary-haskell" "ast-plugin" "get-deps" "hipspec" "hs2ast-tests"
      "hs2ast" "ifcxt" "k-means" "lazy-lambda-calculus" "lazy-smallcheck-2012"
      "ml4hs-helper" "ml4hsfe" "mlspec-bench" "mlspec-helper" "mlspec"
      "nix-eval" "order-deps" "panhandle" "panpipe" "quickspec-measure"
      "quickspec" "reduce-equations" "runtime-arbitrary-tests" "sample-bench"
      "tree-features" "type-parser"
    ];
    haskellSources = map (url: latestGit { inherit url; }) haskellRepos;
  };
};
with lib;
mapAttrs (n: _: import (./tests + "/${n}") { inherit helpers pkgs; })
         (readDir ./tests)
