{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash findutils gnused haskellPackages jq runCabal2nix runCommand
    sanitiseName stdenv;
};
rec {

getCabalFiles = runCommand "get-cabal-files"
  {
    buildInputs = [ findutils gnused jq ];
    LOCATE_PATH = getEnv "LOCATE_PATH";
  }
  ''
    #!${bash}/bin/bash

    function skip {
      grep -v "/NotMine/"                         |
      grep -v "/git-html/"                        |
      grep -v "/ghc/"                             |
      grep -v "/quickspec"                        |
      grep -v "/unification"                      |
      grep -v "/structural-induction"             |
      grep -v "haskell-te/cache/"                 |
      grep -v "haskell-te/packages"
    }

    function dirs {
      [[ -d /home/chris/Programming ]] || return
      while read -r CBL
      do
        if grep "test-suite" < "$CBL" > /dev/null
        then
          echo "$CBL"
        fi
      done < <(locate -e "/home/chris/Programming/*.cabal" | skip)
    }

    dirs | grep '^.' | jq -R '.' | jq -s '.' > "$out"
  '';

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

      function runSuite {
        cabal test "$1" || fail "Failed to run suite $1"
      }

      function suitesFrom {
        tr '[:upper:]' '[:lower:]' < "$1" |
        grep "test-suite"                 |
        cut -d ':' -f2                    |
        sed -e 's/^ *//g'                 |
        sed -e 's/ *$//g'
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

test = stdenv.mkDerivation {
  name         = "cabal-tests";
  buildInputs  = map mkTest cabalFiles;
  installPhase = ''echo "Pass" > "$out"'';
};

}
