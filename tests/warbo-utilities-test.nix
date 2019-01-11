{ helpers, pkgs }:

with pkgs;
with {
  env = withNix {
    utils = latestGit { url = helpers.repoOf "warbo-utilities"; };
  };
};
wrap {
  name   = "warbo-utilities-test";
  paths  = env.buildInputs;
  vars   = env;
  script = ''
    #!/usr/bin/env bash
    set -e
    cd "$utils"
    ./check.sh
    nix-build --no-out-link
  '';
}
