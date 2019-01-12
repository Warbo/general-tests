{ pkgs, helpers }:

with builtins;
with pkgs;
with lib;
with rec {
  MINIMUM = 30;  # Coverage below this % will cause a failure

  env = withNix {};

  checkRepo = pkgName: repo:
    with { cfg = helpers.haskellDeps.utils.phaseConfig pkgName "coverage"; };
    wrap {
      name  = "haskell-coverage-${pkgName}";
      paths =
        with rec {
          # Look up an appropriate version of GHC for this package, if specified
          hsVer  = cfg.ghc or null;
          hsPkgs = if cfg ? ghc
                      then getAttr cfg.ghc haskell.packages
                      else haskellPackages;
        };
        concatLists [
          [ bash cabal-install2 fail findutils hsPkgs.ghc xidel ]
          (cfg.buildInputs or [])
          env.buildInputs
        ];
    vars  = env // {
      inherit pkgName repo;
      extra   = helpers.haskellDeps.utils.genCabalProjectLocal cfg;
      MINIMUM = toString MINIMUM;
    };
    script = ''
      #!/usr/bin/env bash
      set -e

      ${helpers.initHaskellTest}

      if [[ -e shell.nix ]]
      then
        nix-shell --run \
          'cabal new-test --enable-tests --enable-library-coverage' ||
          fail "Cabal failed"
      else
        cabal new-test --enable-tests --enable-library-coverage ||
          fail "Cabal failed"
      fi

      FOUND=0
      while read -r HTML
      do
        FOUND=1

        # Look up % from table, using a tricky XPath query
        TOTAL='th[contains(text(),"Program Coverage Total")]'
        PERCENT='following-sibling::td[1]/text()'
        RAW=$(xidel - --extract "//$TOTAL/$PERCENT" < "$HTML")

        MSG="File '$HTML' has coverage '$RAW', requires $MINIMUM"
        echo "$MSG" 1>&2

        # Remove % for comparison. 0 is denoted "-", so switch that out.
        RESULT=$(echo "$RAW" | tr -d '%' | tr - 0)

        # Check against minimum
        [[ "$RESULT" -lt "$MINIMUM" ]] && fail "$MSG"
      done < <(find . -name "hpc_index.html")

      [[ "$FOUND" -eq 1 ]] || fail "Didn't find any coverage report"
    '';
  };
};

mapAttrs checkRepo helpers.myHaskellRepos
