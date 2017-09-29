{ pkgs, helpers }:

with builtins;
with rec {
  inherit (pkgs)
    lib nixpkgs1703 runCommand xidel;

  inherit (lib)
    mapAttrs;

  inherit (helpers)
    haskellTinced myHaskell;

  checkRepo = name: repo:
    runCommand "haskell-coverage-${name}"
      {
        results      = with nixpkgs1703.haskell.lib;
                       doCoverage (doCheck (haskellTinced {
                         inherit repo;
                         haskellPkgs = nixpkgs1703.haskell.packages.ghc7103;
                       }));
        buildInputs  = [ xidel ];
        MINIMUM      = "30";  # Coverage below this % will cause a failure
      }
      ''
        set -e
        while read -r HTML
        do
          # Look up % from table, using a tricky XPath query
          TOTAL='th[contains(text(),"Program Coverage Total")]'
          PERCENT='following-sibling::td[1]/text()'
          RAW=$(xidel - --extract "//$TOTAL/$PERCENT" < "$HTML")

          echo "File '$HTML' has coverage '$RAW', requires $MINIMUM" 1>&2

          # Remove % for comparison. 0 is denoted "-", so switch that out.
          RESULT=$(echo "$RAW" | tr -d '%' | tr - 0)

          # Check against minimum
          [[ "$RESULT" -lt "$MINIMUM" ]] && exit 1
          echo "Passed" > "$out"
        done < <(find "$results" -name "hpc_index.html")
      '';
};

mapAttrs checkRepo myHaskell
