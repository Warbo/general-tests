{ helpers, pkgs }:
with builtins;
with pkgs;
with lib;
with rec {
  env = withNix {};

  nix-helpers = pkgs.fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "72d9d88";
    sha256 = "1kggqr07dz2widv895wp8g1x314lqg19p67nzr3b97pg97amhjsi";
  };

  check = pkgName: repo: wrap {
    name   = "${pkgName}-release-builds";
    paths  = [ bash ] ++ env.buildInputs;
    vars   = env // {
      inherit pkgName repo;
      ATTRS = ''
        (with import ${nix-helpers}; drvPathsIn (import (./. + "/release.nix")))
       '';
    };
    script = ''
      #!/usr/bin/env bash
      set -e

      # Clone/pull the repo and pushd inside
      ${helpers.cacheRepo}

      echo "Finding derivations from release.nix" 1>&2
      DRVPATHS=$(nix eval --show-trace --raw "$ATTRS")

      echo "Building derivations" 1>&2
      while read -r PAIR
      do
        ATTR=$(echo "$PAIR" | cut -f1)
         DRV=$(echo "$PAIR" | cut -f2)
        echo "Building $ATTR" 1>&2
        nix-store --show-trace --realise "$DRV" ||
          fail "Couldn't build '$ATTR' ($DRV)"
      done < <(echo "$DRVPATHS")
      exit 0
    '';
  };
};
mapAttrs check {
  inherit (helpers.myReposUnhashed) haskell-te panpipe;
}
