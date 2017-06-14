{ pkgs ? import <nixpkgs> {} }:
with builtins;
with pkgs;
with lib;
with rec {

  # Use this for helper functions, etc. common to many tests
  helpers = rec {
    getGit = url: latestGit { inherit url; };

    repoOf = r:
      let given = getEnv "GIT_REPO_DIR";
          local = if given == ""
                     then "/home/chris/Programming/repos/${r}.git"
                     else "${given}/${r}.git";
       in if pathExists local
             then local
             else "http://chriswarbo.net/git/${r}.git";

    haskellRepos = map repoOf (attrNames allHaskell);

    haskellSources = map getGit haskellRepos;

    allHaskell = myHaskell // notMyHaskell;

    inPaths = n: any ({ path, prefix }: n == prefix) nixPath;

    findRepo = n: v: if inPaths n
                        then toString v
                        else getGit (repoOf n);

    inputFallback = name:
      with rec {
        found = fold (this: result: if this.prefix == name
                                       then this.path
                                       else result)
                     null
                     nixPath;
      };
      if found == null
         then getGit (repoOf name)
         else found;

    myHaskell = genAttrs [
        "arbitrary-haskell"
        "ast-plugin"
        "get-deps"
        "hs2ast-tests"
        "hs2ast"
        "k-means"
        "lazy-lambda-calculus"
        "ml4hs-helper"
        "ml4hsfe"
        "mlspec-bench"
        "mlspec-helper"
        "mlspec"
        "nix-eval"
        "order-deps"
        "panhandle"
        "panpipe"
        "quickspec-measure"
        "reduce-equations"
        "runtime-arbitrary-tests"
        "tree-features"
        "type-parser"
      ]
      inputFallback;

    notMyHaskell = genAttrs [
        "hipspec"
        "ifcxt"
        "lazy-smallcheck-2012"
        "quickspec"
      ]
      inputFallback;

    haskellSrcDeps = repo:
      with rec {
        # Use cabal2nix to generate a derivation function, then use that
        # function's arguments to figure out what dependencies we need to
        # include
        haskellDef = import (runCabal2nix { url = toString repo; });
      };
      filter (p: !(elem p [ "mkDerivation" "stdenv" ]))
             (attrNames (functionArgs haskellDef));

    # Sets up an environment to build a Haskell package from the given repo.
    # The step should be one of "configure", "build", "test" or "coverage",
    # which lets us stop early, e.g. "build" will stop after building.
    compileHaskell = repo: step:
      stdenv.mkDerivation {
        inherit step;
        name = "haskell-${step}";
        src  = repo;
        buildInputs  = [
          haskellPackages.happy
          zlib.out
          haskellPackages.cabal-install
          (haskellPackages.ghcWithPackages (h: map (p: h."${p}")
                                                   (haskellSrcDeps repo)))
        ];
        configFlags  = concatStringsSep " " [
          (if step == "coverage"
              then "--enable-coverage"
              else "")
          (if elem step ["test" "coverage"]
              then "--enable-tests"
              else "")
        ];
        buildCommand = ''
          set -e

          function fail {
            echo "$*" 1>&2
            exit 1
          }

          function succeed {
            cp -r . "$out"
            exit
          }

          echo "Making mutable copy of source" 1>&2
          cp -r "$src" ./src
          chmod +w -R ./src
          cd ./src

          echo "Configuring" 1>&2
          export HOME="$PWD"
          cabal configure $configFlags || fail "Failed to configure"
          [[ "x$step" = "xconfigure" ]] && succeed

          echo "Building" 1>&2
          cabal build || fail "Failed to build"
          [[ "x$step" = "xbuild" ]] && succeed

          echo "Testing" 1>&2
          cabal test || fail "Failed to test"
          succeed
        '';
      };


    combineTests = name: tests:
      tests // {
        test = stdenv.mkDerivation {
          inherit name;
          buildInputs  = attrValues tests;
          buildCommand = ''
            echo "Pass" > "$out"
          '';
        };
      };
  };
};
with lib;
listToAttrs (map (f: {
                   name  = removeSuffix ".nix" f;
                   value = import (./tests + "/${f}") { inherit helpers pkgs; };
                 })
                 (attrNames (readDir ./tests)))
