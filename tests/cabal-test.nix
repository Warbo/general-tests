{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash findutils gnused haskellPackages jq latestGit runCabal2nix runCommand
    sanitiseName stdenv;
  inherit (helpers)
    haskellRepos;
};
rec {
/*
getCabalFiles = stdenv.mkDerivation {
  name         = "cabal-files";
  repos        = map (url: latestGit { inherit url; }) haskellRepos;
  buildInputs  = [ findutils gnused jq ];
  LOCATE_PATH  = getEnv "LOCATE_PATH";
  buildCommand = ''
    function skip {
      grep -v "/NotMine/"             |
      grep -v "/git-html/"            |
      grep -v "/ghc/"                 |
      grep -v "/quickspec"            |
      grep -v "/unification"          |
      grep -v "/structural-induction" |
      grep -v "haskell-te/cache/"     |
      grep -v "haskell-te/packages"
    }

    function dirs {
      echo "Looking for Cabal files on disk" 1>&2
      [[ -d /home/chris/Programming ]] || return
      while read -r CBL
      do
        if grep "test-suite" < "$CBL" > /dev/null
        then
          echo "$CBL"
        fi
      done < <(locate -e "/home/chris/Programming/*.cabal" | skip)
    }

    function fromRepos {
      echo "Looking for Cabal files online" 1>&2
      for REPO in $repos
      do
        echo "Checking repo $REPO" 1>&2
        for F in "$REPO"/*
        do
          if echo "$F" | grep "\.cabal$" > /dev/null
          then
            echo "Found $F" 1>&2
            echo "$F"
          fi
        done
      done
    }

    function cabalFiles {
      dirs
      fromRepos
    }

    cabalFiles | grep '^.' | jq -R '.' | jq -s '.' > "$out"
  '';
};

cabalFiles = fromJSON (readFile "${getCabalFiles}");

mkTest = cabalFile:
  with rec {
    dir         = dirOf cabalFile;

    # Use cabal2nix to generate a derivation function, then use that function's
    # arguments to figure out what dependencies we need to include
    haskellDef  = import (runCabal2nix { url  = dir; });
    haskellArgs = filter (p: !(elem p [ "mkDerivation" "stdenv" ]))
                         (attrNames (functionArgs haskellDef));

    # Some Haskell packages will only work with particular versions of GHC
    version     = if hasSuffix "sample-bench.cabal" cabalFile
                     then haskell.packages.ghc783
                     else haskellPackages;
  };
  stdenv.mkDerivation {
    name = "cabal-test-${sanitiseName dir}";
    src  = filterSource
             (path: type: !(elem (baseNameOf path)
                                 [ ".cabal-sandbox" ".git"
                                   "cabal.sandbox.config" "dist" ]))
             dir;
    buildInputs  = [
      haskellPackages.cabal-install
      (haskellPackages.ghcWithPackages (h: map (p: h."${p}") haskellArgs))
    ];
    buildCommand = ''
      set -e

      function fail {
        echo "$*" 1>&2
        exit 1
      }

      echo "Making mutable copy of source" 1>&2
      cp -r "$src" ./src
      chmod +w -R ./src
      cd ./src

      echo "Configuring" 1>&2
      export HOME="$PWD"
      cabal configure --enable-tests || fail "Failed to configure"

      echo "Testing" 1>&2
      cabal test || fail "Failed to test"

      echo "Passed" > "$out"

      #while read -r HPC
      #do
      #  echo "Storing coverage report from '$HPC'"
      #  mkdir -p ~/Programming/coverage/"$NAME"
      #  cp -vr "$HPC" ~/Programming/coverage/"$NAME/"
      #done < <(find . -type d -name html)
    '';
  };
*/

testRepo = repo:
  with rec {
    # Use cabal2nix to generate a derivation function, then use that function's
    # arguments to figure out what dependencies we need to include
    src         = latestGit { url = repo; };
    haskellDef  = import (runCabal2nix { url = toString src; });
    haskellArgs = filter (p: !(elem p [ "mkDerivation" "stdenv" ]))
                         (attrNames (functionArgs haskellDef));
  };
  stdenv.mkDerivation {
    name = "cabal-test";
    inherit src;
    buildInputs  = [
      haskellPackages.cabal-install
      (haskellPackages.ghcWithPackages (h: map (p: h."${p}") haskellArgs))
    ];
    buildCommand = ''
      set -e

      function fail {
        echo "$*" 1>&2
        exit 1
      }

      echo "Making mutable copy of source" 1>&2
      cp -r "$src" ./src
      chmod +w -R ./src
      cd ./src

      echo "Configuring" 1>&2
      export HOME="$PWD"
      cabal configure --enable-tests || fail "Failed to configure"

      echo "Testing" 1>&2
      cabal test || fail "Failed to test"

      echo "Passed" > "$out"
    '';
  };


test = stdenv.mkDerivation {
  name         = "cabal-tests";
  buildInputs  = map testRepo haskellRepos;
  buildCommand = ''
    echo "Pass" > "$out"
  '';
};

}
