# Use this for helper functions, etc. common to many tests
{ cabal2nix, fail, hackagePackageNames, haskellPackages, latestGit, lib, stdenv,
  tincify, withNix, writeScript }:

with builtins;
with lib;
rec {
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

  # Repos we have forks of, but aren't ours. We don't want to be invasive, so
  # we don't care about coverage, linting, etc.
  notMyHaskell = genAttrs [
      "hipspec"
      "ifcxt"
      "lazy-smallcheck-2012"
      "quickspec"
    ]
    inputFallback;

  # Unmaintained; the repo should persist, but we don't even care if it builds
  oldCode = genAttrs [
      "hs2ast-tests"
      "ml4hs-helper"
      "mlspec-bench"
      "quickspec-measure"
    ]
    inputFallback;

  # Our code; should build, pass tests, pass linters, have coverage, etc.
  myHaskell = genAttrs [
      "arbitrary-haskell"
      "ast-plugin"
      "get-deps"
      "hs2ast"
      "k-means"
      "lazy-lambda-calculus"
      "ml4hsfe"
      "mlspec-helper"
      "mlspec"
      "nix-eval"
      "order-deps"
      "panhandle"
      "panpipe"
      "reduce-equations"
      "runtime-arbitrary-tests"
      "tree-features"
      "type-parser"
    ]
    inputFallback;

  # The Cabal project name for each Haskell repo. Usually this matches the
  # repo name (e.g. "foo.git" is "foo"), but there are exceptions.
  hsName =
    with {
      overrides = {
        ast-plugin = "AstPlugin";
        ml4hsfe    = "ML4HSFE";
      };
    };
    repo: if hasAttr repo overrides
             then getAttr repo overrides
             else repo;

  haskellSrcDeps = repo:
    with rec {
      deps = {
        ml4hsfe = [ "HS2AST" "weigh" ];
      };
    };
    if hasAttr repo deps then getAttr repo deps else [];

  haskellTinced = repo:
    with rec {
      haskellDef = import (runCabal2nix { url = getGit (repoOf repo); });

      extras = filter (p: if elem p [ "mkDerivation" "stdenv" ]
                             then false
                             else if hasAttr p haskellPackages &&
                                     getAttr p haskellPackages == null
                                     then false
                                     else !(elem p hackagePackageNames))
                      (attrNames (functionArgs haskellDef));
    };
    tincify ((haskellPackages.callPackage haskellDef {}) // {
              inherit extras;
              includeExtras = true;
            }) {};

  # Sets up an environment to build a Haskell package from the given repo.
  # The step should be one of "configure", "build", "test" or "coverage",
  # which lets us stop early, e.g. "build" will stop after building.
  compileHaskell = name: repo: step:
    stdenv.mkDerivation (withNix {
      inherit step;
      name         = "haskell-${step}";
      src          = repo;
      buildInputs  = [ cabal2nix fail (haskellTinced repo).env ];
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

        function succeed {
          cp -r . "$out"
          exit
        }

        export HOME="$PWD"

        echo "Making mutable copy of source" 1>&2
        cp -r "$src" ./src
        chmod +w -R ./src
        cd ./src

        echo "Configuring" 1>&2
        cabal configure $configFlags || fail "Failed to configure"

        if [[ "x$step" = "xconfigure" ]]
        then
          succeed
        fi

        echo "Building" 1>&2
        cabal build || fail "Failed to build"
        [[ "x$step" = "xbuild" ]] && succeed

        echo "Testing" 1>&2
        cabal test || fail "Failed to test"
        succeed
      '';
    });
}
