{ helpers, pkgs }:
with pkgs;
wrap {
  name   = "all-committed";
  paths  = [ bash fail findutils git ];
  script = ''
    #!/usr/bin/env bash
    set -e

    function data {
      if [[ -e ~/Programming ]]
      then
        find ~/Programming -type d -name '.git' |
          grep -v "/git-html/" |
          grep -v "/ATS/aos"
      fi
    }

    function gitClean {
      if ! git status | grep "nothing to commit, working directory clean" > /dev/null
      then
        ERR=1
        echo "Uncommited things in '$1'" 1>&2
      fi
    }

    ERR=0
    while IFS= read -r REPO
    do
      DIR=$(dirname "$REPO")
      [[ -e "$DIR" ]] || continue
      cd "$DIR" || { ERR=1; continue; }
      gitClean "$DIR"
    done < <(data)

    exit "$ERR"
  '';
}
