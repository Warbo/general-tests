{ pkgs, helpers }:
with builtins;
with pkgs;
with lib;
with rec {
  env = withNix {};

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
        concatLists [
          [ bash cabal-install2 fail findutils hsPkgs.ghc ]
          (cfg.buildInputs or [])
          env.buildInputs
        ];
      vars  = env // {
        inherit pkgName repo;
        extra = helpers.haskellDeps.utils.genCabalProjectLocal cfg;
      };
      script = ''
        #!/usr/bin/env bash
        set -e

        ${helpers.initHaskellTest}

        if [[ -e shell.nix ]]
        then
          nix-shell --run 'cabal new-test --enable-tests' ||
            fail "Cabal tests failed"
        else
          cabal new-test --enable-tests || fail "Cabal tests failed"
        fi
      '';
    };
};
mapAttrs testRepo helpers.myHaskellRepos
