{ helpers, pkgs }:
with builtins;
with pkgs;
with lib;
with {
  repos = import (runCommand "git-repos.nix"
    { inherit (helpers) findIgnoringPermissions HOME; }
    ''
      function repos {
        for D in Programming warbo-utilities nix-config System/Tests
        do
          D="$HOME/$D"
          [[ -e "$D" ]] || continue

          "$findIgnoringPermissions" "$D" -type d -name '.git' |
            grep -v "/git-html/" |
            grep -v "/ATS/aos"
        done
      }

      function entries {
        while read -r REPO
        do
           DIR=$(dirname "$REPO")
          NAME=$(basename "$DIR")
          HASH=$(echo "$DIR" | sha256sum | cut -d ' ' -f1)
          echo "\"$HASH-$NAME\" = \"$DIR\";"
        done < <(repos)
      }

      echo '{'   > "$out"
        entries >> "$out"
      echo '}'  >> "$out"
    '');

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
mapAttrs check repos
