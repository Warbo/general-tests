{ pkgs, helpers }:

with {
  inherit (pkgs)
    stdenv;
};
rec {
  getRepos = stdenv.mkDerivation {
    name = "haskell-repos";
    buildCommand = ''
      function repos {
        wget -O- 'http://chriswarbo.net/git' |
          grep -o '<a .*</a>'                |
          grep -o 'href=".*/"'               |
          grep -v '\.git/"'                  |
          grep -o '".*"'                     |
          grep -o '[^"/]*'
      }

      function haskellRepos {
        while read -r REPO
        do
          if wget -O- "http://chriswarbo.net/git/$REPO/branches/master" |
               grep '\.cabal</a>' > /dev/null
          then
            echo "$REPO"
          fi
        done < <(repos)
      }

      echo "[" > "$out"
      while read -r NAME
      do
        echo "http://chriswarbo.net/git/$REPO.git" >> "$out"
      done < <(haskellRepos)
      echo "]" > "$out"
    '';
  };

  test = stdenv.mkDerivation {
    name  = "haskell-repos-included";
    repos = getRepos;
    given = helpers.haskellRepos;
    buildCommand = ''
      for REPO in $given
      do
        grep -Fx "$REPO" < "$repos" || {
          echo "Given repo '$REPO', but didn't find it online" 1>&2
          exit 1
        }
      done

      while read -r REPO
      do
        FOUND=0
        for GIVEN in $given
        do
          if [[ "x$GIVEN" = "x$REPO" ]]
          then
            FOUND=1
          fi
        done
        [[ "$FOUND" -eq 1 ]] || {
          echo "Found '$REPO' online, but wasn't given" 1>&2
          exit 1
        }
      done < "$repos"

      echo "Passed" > "$out"
    '';
  };
}
