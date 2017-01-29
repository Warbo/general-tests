{ pkgs, helpers }:

with builtins;
with {
  inherit (pkgs)
    lib stdenv wget;
  inherit (helpers)
    haskellRepos;
  inherit (pkgs.lib)
    fold;
};

rec {
  getRepos = stdenv.mkDerivation {
    name         = "haskell-repos";
    buildInputs  = [ wget ];
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

      while read -r NAME
      do
        echo "http://chriswarbo.net/git/$NAME.git" >> "$out"
      done < <(haskellRepos)
    '';
  };

  # Repos which get flagged as Haskell, despite not being so
  nonHaskellRepos = map (r: "http://chriswarbo.net/git/${r}.git") [
    "haskell-te" "isahipster" "writing"
  ];

  test = assert fold (repo: _:
                       if elem repo haskellRepos
                          then error "'${repo}' shouldn't be in haskellRepos"
                          else true)
                     true
                     nonHaskellRepos;
  stdenv.mkDerivation {
    name  = "haskell-repos-included";
    repos = getRepos;
    given = haskellRepos ++ nonHaskellRepos;
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

      touch "$out"
    '';
  };
}
