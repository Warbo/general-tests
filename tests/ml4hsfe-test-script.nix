{ helpers, pkgs }:
with builtins;
with pkgs;
with { src = helpers.inputFallback "ml4hs"; };
wrap {
  name   = "ml4hs-tests";
  paths  = (withNix {}).buildInputs ++ [ bash fail ];
  vars   = withNix {
    inherit src;
    names = nixListToBashArray {
      name = "ATTRNAMES";
      args = attrNames (import "${src}/overlayed.nix").ml4hsfeTests;
    };
  };
  script = ''
    #!/usr/bin/env bash
    set -e
    for NAME in "$names[@]"
    do
      nix-build --no-out-link --show-trace \
        -E "(import \"$src\").ml4hsfeTests.$NAME" || fail "Couldn't build $NAME"
    done
    echo "All passed" 1>&2
    exit 0
  '';
}
