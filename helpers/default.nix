# Use this for helper functions, etc. common to many tests
{ cabal2nix, fail, hackagePackageNames, haskellPackages, latestGit, lib,
  runCabal2nix, stdenv, tincify, withNix, writeScript }:

with builtins;
with lib;
rec {
  getGit = url:
    assert isString url || abort (toJSON {
      inherit url;
      message = "getGit URL should be a string";
    });
    latestGit { inherit url; };

  repoOf = r:
    with rec {
      isStore = hasPrefix storeDir r;
      given   = getEnv "GIT_REPO_DIR";
      local   = if given == ""
                   then "/home/chris/Programming/repos/${r}.git"
                   else "${given}/${r}.git";
      exists  = pathExists local;
      remote  = "http://chriswarbo.net/git/${r}.git";
      debug   = message: abort (toJSON {
                  inherit message r;
                  typeOfR = typeOf r;
                });
    };
    assert isString r || debug "repoOf should be given a string";
    assert !isStore   || debug "repoOf should not be given store path";
    if exists then local else remote;

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

  haskellTinced = { haskellPkgs ? haskellPackages, repo }:
    with rec {
      haskellDef = import (runCabal2nix { url = repo; });

      extras     = filter (p: if elem p [ "mkDerivation" "stdenv" ]
                                 then false
                                 else if hasAttr p haskellPkgs &&
                                         getAttr p haskellPkgs == null
                                         then false
                                         else !(elem p hackagePackageNames))
                          (attrNames (functionArgs haskellDef));
    };
    tincify ((haskellPkgs.callPackage haskellDef {}) // {
              inherit extras;
              haskellPackages = haskellPkgs;
            }) {};
}
