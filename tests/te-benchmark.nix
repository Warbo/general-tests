{ helpers, pkgs }:
with pkgs;
with {
  nix-helpers = fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "72d9d88";
    sha256 = "1kggqr07dz2widv895wp8g1x314lqg19p67nzr3b97pg97amhjsi";
  };
};
wrap {
  name = "te-benchmark-tests";
  paths = (withNix {}).buildInputs;
  vars = withNix {
    expr = ''(with import ${nix-helpers};
             drvPathsIn ((import ./. {}).tests { full = true; }))'';

    pkgName = "theory-exploration-benchmarks";
    repo    = helpers.myReposUnhashed."theory-exploration-benchmarks";
  };
  script = ''
    #!/usr/bin/env bash
    set -e

    # Clone/pull the repo and pushd inside
    ${helpers.cacheRepo}

    echo "Finding test derivations" 1>&2
    ATTRS=$(nix eval --show-trace --raw "$expr")

    while read -r PAIR
    do
      ATTR=$(echo "$PAIR" | cut -f1)
       DRV=$(echo "$PAIR" | cut -f2)

      echo "Building $ATTR" 1>&2
      nix-store --show-trace --realise "$DRV" ||
        fail "Couldn't build '$ATTR' ($DRV)"
    done < <(echo "$ATTRS")

    echo "pass"
  '';
}
