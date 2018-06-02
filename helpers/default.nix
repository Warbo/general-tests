# Use this for helper functions, etc. common to many tests
{ bash, cabal2nix, die, fail, file, findutils, hackagePackageNames,
  haskellPackages, haskellPkgWithDeps, latestGit, lib, repoSource, runCabal2nix,
  runCommand, stdenv, utillinux, withNix, wrap, writeScript }:

with builtins;
with lib;
rec {
  notImplemented = name: wrap {
    inherit name;
    paths  = [ bash ];
    script = ''
      #!/usr/bin/env bash
      exit 1
    '';
  };

  getGit = url:
    assert isString url || abort (toJSON {
      inherit url;
      message = "getGit URL should be a string";
    });
    latestGit { inherit url; stable = { unsafeSkip = true; }; };

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

  haskellStandalone = { haskellPkgs ? haskellPackages, repo }:
    with rec {
      haskellDef    = import (runCabal2nix { url = repo; });

      extra-sources = filter (p: if elem p [ "mkDerivation" "stdenv" ]
                                    then false
                                    else if hasAttr p haskellPkgs &&
                                            getAttr p haskellPkgs == null
                                            then false
                                            else !(elem p hackagePackageNames))
                             (attrNames (functionArgs haskellDef));
    };
    haskellPkgWithDeps {
      inherit extra-sources;
      delay-failure = true;
      dir           = repo;
      hsPkgs        = haskellPkgs;
    };

  HOME = if pathExists /home/chris
    then "/home/chris"
    else "/homeless-shelter";

  findIgnoringPermissions = wrap {
    name   = "find-ignoring-permissions";
    paths  = [ bash findutils ];
    script = ''
      #!/usr/bin/env bash

      function ignorePermission {
        grep -v 'Permission denied$' || true
      }

      find "$@" 2> >(ignorePermission 1>&2) || true
    '';
  };

  myShellscripts = import (runCommand "my_shellscripts"
    {
      inherit findIgnoringPermissions HOME;
      buildInputs = [ file utillinux ];
      cacheBust = toString (currentTime / 3600);
      script    = ./my_shellscripts.sh;
    }
    ''
      echo '{' > "$out"
        "$script" | while read -r S
        do
          N=$(basename "$S")
          H=$(echo     "$S" | sha256sum | cut -d ' ' -f1)
          echo "\"$H-$N\" = \"$S\";"
        done >> "$out"
      echo '}' >> "$out"
    '');
}
