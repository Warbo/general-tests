{ helpers, pkgs }:
with pkgs;
runCommand "all-committed"
  {
    buildInputs = [ findutils git ];
  }
  ''
    function data {
      if [[ -e /home/chris/Programming ]]
      then
        find /home/chris/Programming -type d -name '.git' |
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

    [[ "$ERR" -eq 1 ]] || echo "Pass" > "$out"
    exit "$ERR"
  ''
