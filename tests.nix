{ pkgs ? import <nixpkgs> {} }:
with builtins;

with rec {
  inherit (pkgs)
    haskellPackages latestGit lib runCabal2nix stdenv;

  inherit (lib)
    concatStringsSep;

  # Use this for helper functions, etc. common to many tests
  helpers = rec {
    getGit = url: latestGit { inherit url; };

    repoOf = r: "http://chriswarbo.net/git/${r}.git";

    haskellRepos = map repoOf (attrNames allHaskell);

    haskellSources = map getGit haskellRepos;

    allHaskell = myHaskell // notMyHaskell;

    myHaskell = {
      arbitrary-haskell       = <arbitrary-haskell>;
      ast-plugin              = <ast-plugin>;
      get-deps                = <get-deps>;
      hs2ast-tests            = <hs2ast-tests>;
      hs2ast                  = <hs2ast>;
      k-means                 = <k-means>;
      lazy-lambda-calculus    = <lazy-lambda-calculus>;
      ml4hs-helper            = <ml4hs-helper>;
      ml4hsfe                 = <ml4hsfe>;
      mlspec-bench            = <mlspec-bench>;
      mlspec-helper           = <mlspec-helper>;
      mlspec                  = <mlspec>;
      nix-eval                = <nix-eval>;
      order-deps              = <order-deps>;
      panhandle               = <panhandle>;
      panpipe                 = <panpipe>;
      quickspec-measure       = <quickspec-measure>;
      reduce-equations        = <reduce-equations>;
      runtime-arbitrary-tests = <runtime-arbitrary-tests>;
      sample-bench            = <sample-bench>;
      tree-features           = <tree-features>;
      type-parser             = <type-parser>;
    };

    notMyHaskell = [
      hipspec              = <hipspec>;
      ifcxt                = <ifcxt>;
      lazy-smallcheck-2012 = <lazy-smallcheck-2012>;
      quickspec            = <quickspec>;
    ];

    haskellSrcDeps = repo:
      with rec {
        # Use cabal2nix to generate a derivation function, then use that
        # function's arguments to figure out what dependencies we need to
        # include
        src        = getGit repo;
        haskellDef = import (runCabal2nix { url = toString src; });
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
        src  = getGit repo;
        buildInputs  = [
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
