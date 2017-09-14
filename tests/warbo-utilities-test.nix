{ helpers, pkgs }:
with pkgs;
runCommand "warbo-utilities"
  (withNix {
    utils = latestGit { url = helpers.repoOf "warbo-utilities"; };
  })
  ''
    cd "$utils"
    ./test.sh
    echo "pass" > "$out"
  ''
