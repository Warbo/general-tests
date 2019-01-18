{ pkgs, helpers }:
with pkgs;
wrap {
  name   = "ml4pg";
  vars   = withNix { src = helpers.inputFallback "ml4pg"; };
  paths  = (withNix {}).buildInputs ++ [ bash ];
  script = ''
    #!/usr/bin/env bash
    set -e
    nix-build --show-trace --no-out-link \
      -E "(import \"$src/release.nix\").stable.ml4pg"
  '';
}
