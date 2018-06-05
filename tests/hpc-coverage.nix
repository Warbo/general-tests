{ pkgs, helpers }:

with builtins;
with pkgs;
with lib;
with {
  checkRepo = pkgName: repo: wrap {
    name  = "haskell-coverage-${pkgName}";
    paths = with rec {
      # Look up an appropriate version of GHC for this package, if specified
      hsVer  = helpers.haskellDeps."${pkgName}".ghc or null;
      hsPkgs = if hsVer == null
                  then haskellPackages
                  else getAttr hsVer haskell.packages;
    };
    [ bash cabal-install2 fail findutils hsPkgs.ghc xidel  ];
    vars  = {
      inherit pkgName repo;
      MINIMUM = "30";  # Coverage below this % will cause a failure
    };
    script = ''
      #!/usr/bin/env bash
      set -e

      D=$(mktemp -d --tmpdir 'test-hpc-coverage-$pkgName-XXXXX')
      function cleanup {
        rm -rf "$D" || true
      }
      trap cleanup EXIT

      cd "$D" || fail "Couldn't cd to temp dir '$D'"

      cp -r "$repo" ./src
      chmod +w -R   ./src
      cd            ./src
      cabal new-test --enable-library-coverage || fail "Cabal failed"

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

mapAttrs checkRepo helpers.myHaskell
