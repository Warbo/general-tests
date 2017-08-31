{ pkgs, helpers }:

with builtins;
with rec {
  inherit (pkgs)
    lib stdenv xidel;

  inherit (lib)
    mapAttrs;

  inherit (helpers)
    compileHaskell myHaskell repoOf;

  checkRepo = name: repo:
    stdenv.mkDerivation {
      name         = "haskell-coverage";
      results      = compileHaskell name repo "coverage";
      buildInputs  = [ xidel ];
      MINIMUM      = "30";  # Coverage below this % will cause a failure
      buildCommand = ''
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

  tests = mapAttrs checkRepo myHaskell;
};

tests
