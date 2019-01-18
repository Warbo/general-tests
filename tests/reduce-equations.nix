{ helpers, pkgs }:
with pkgs;
wrap {
  name   = "reduce-equations";
  paths  = [ bash fail ] ++ (withNix {}).buildInputs;
  vars   = withNix {
    dir = helpers.inputFallback "reduce-equations";
  };
  script = ''
    #!/usr/bin/env bash
    set -e
    D=$(mktemp -d --tmpdir general-tests-reduce-equations-XXXXX)

    function cleanup {
      rm -rf "$D"
    }
    trap cleanup EXIT

    cd "$D" || fail "Couldn't cd to '$D'"
    cp -r "$dir" ./src
    chmod +w -R  ./src
    cd ./src || exit 1
    nix-shell --run './test.sh' || fail "test.sh failed"
  '';
}
