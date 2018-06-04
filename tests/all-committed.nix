{ helpers, pkgs }:
with builtins;
with pkgs;
with lib;
with {
  check = name: repo: wrap {
    name   = "all-committed-${name}";
    paths  = [ bash fail git ];
    vars   = { inherit repo; };
    script = ''
      #!/usr/bin/env bash
      set -e

      function check {
        echo "$1" | grep "nothing to commit" > /dev/null
      }

      [[ -e "$repo" ]] || fail "Repo '$repo' doesn't exist"
      cd "$repo"       || fail "Couldn't cd to '$repo'"
      S=$(git status)  || fail "Couldn't get status of '$repo'"
      check "$S"       || fail "Uncommited things in '$repo'"
    '';
  };
};
mapAttrs check helpers.localRepos
