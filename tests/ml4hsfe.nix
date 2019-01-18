{ helpers, pkgs }:
with builtins;
with pkgs;
with { src = helpers.inputFallback "ml4hsfe"; };
with nixListToBashArray {
  name = "ATTRNAMES";
  args = attrNames (removeAttrs (import "${src}/overlayed.nix").ml4hsfeTests
                                [ "override" "overrideDerivation" ]);
};
wrap {
  name   = "ml4hs-tests";
  paths  = (withNix {}).buildInputs ++ [ bash fail ];
  vars   = withNix (env // { inherit src; });
  script = ''
    #!/usr/bin/env bash
    set -e

    ${code}

    for NAME in "''${ATTRNAMES[@]}"
    do
      nix-build --no-out-link --show-trace \
        -E "(import \"$src/overlayed.nix\").ml4hsfeTests.$NAME" ||
          fail "Couldn't build $NAME"
    done
    echo "All passed" 1>&2
    exit 0
  '';
}
