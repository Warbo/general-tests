{ pkgs, helpers }:

with builtins;
with rec {
  inherit (pkgs)
    lib stdenv xidel;

  inherit (lib)
    mapAttrs;

  inherit (helpers)
    combineTests compileHaskell myHaskell repoOf;

  checkRepo = repo:
    stdenv.mkDerivation {
      name         = "haskell-coverage";
      results      = compileHaskell repo "coverage";
      buildInputs  = [ xidel ];
      MINIMUM      = "30";  # Coverage below this % will cause a failure
      buildCommand = ''
        shopt -s nullglob
        FOUND=0
        while read -r HTML
        do
            FOUND=1
            TOTAL='th[contains(text(),"Program Coverage Total")]'
            PERCENT='following-sibling::td[1]/text()'
            RAW=$(xidel - --extract "//$TOTAL/$PERCENT" < "$HTML")
            RESULT=$(echo "$RAW" | tr -d '%')
            echo "File '$HTML' has coverage '$RAW'"
            if echo "$RESULT" | grep "[^0-9]" > /dev/null
            then
                # 0 shows up as "-", so fix it
                echo "Percentage looks non-numeric; assuming 0"
                RESULT=0
            fi
            if [[ "$RESULT" -lt "$MINIMUM" ]]
            then
                echo "'$RESULT' coverage for '$HTML'" 1>&2
                exit 1
            fi
        done < <(find "$results" -name "hpc_index.html")

        [[ "$FOUND" -eq 1 ]] || {
          echo "Found no coverage report" 1>&2
          exit 1
        }
      '';
    };

  tests = mapAttrs (_: checkRepo) myHaskell;
};

combineTests "hpc-coverage" tests
