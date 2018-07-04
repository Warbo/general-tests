{ pkgs, helpers }:
with builtins;
with pkgs;
with lib;
with {
  testRepo = pkgName: repo:
  with { cfg = helpers.haskellDeps.utils.phaseConfig pkgName "coverage"; };
  wrap {
    name  = "cabal-test-${pkgName}";
    paths =
      with rec {
        # Look up an appropriate version of GHC for this package, if specified
        hsVer  = cfg.ghc or null;
        hsPkgs = if cfg ? ghc
                    then getAttr cfg.ghc haskell.packages
                    else haskellPackages;
      };
      [ bash cabal-install2 fail findutils hsPkgs.ghc ] ++
        (cfg.buildInputs or []);
    vars  = {
      inherit pkgName repo;
      cache = "/tmp/general-tests-cache/git-repos";
      extra = helpers.haskellDeps.utils.genCabalProjectLocal cfg;
    };
    script = ''
      #!/usr/bin/env bash
      set -e

      ${helpers.initHaskellTest}

      cabal new-test --enable-tests || fail "Cabal tests failed"
    '';
  };
};
mapAttrs testRepo helpers.myHaskellRepos
