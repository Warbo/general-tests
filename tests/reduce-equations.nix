{ helpers, pkgs }:
with pkgs;
with rec {
  repo = helpers.inputFallback "reduce-equations";
  re   = runCabal2nix { url = "${repo}"; };
};
runCommand "reduce-equations"
  {
    inherit repo;
    buildInputs = [ fail jq re ];
  }
  ''
    set -e
    set -o pipefail

    for F in "$repo"/test/data/*.json
    do
      reduce-equations < "$F" | jq -es '. | length | . > 0' ||
        fail "No eqs for $F"
    done

    echo pass > "$out"
  ''
