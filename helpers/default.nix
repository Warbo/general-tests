# Use this for helper functions, etc. common to many tests
{ bash, cabal2nix, callPackage, die, dropWhile, fail, file, findutils, git,
  hackagePackageNames, haskellPackages, haskellPkgWithDeps, latestGit, lib,
  repoSource, runCabal2nix, runCommand, stdenv, utillinux, withNix, wrap,
  writeScript }:

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

  flattenToPaths = callPackage ./flattenToPaths.nix {};

  getGit = url:
    assert isString url || abort (toJSON {
      inherit url;
      message = "getGit URL should be a string";
    });
    latestGit { inherit url; stable = { unsafeSkip = true; }; };

  repoOf = r:
    with {
      isStore = hasPrefix storeDir r;
      debug   = message: die { inherit message r; typeOfR = typeOf r; };
    };
    assert isString r || debug "repoOf should be given a string";
    assert !isStore   || debug "repoOf should not be given store path";
    "${repoSource}/${r}.git";

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

  haskellDeps = callPackage ./haskellDeps.nix { inherit inputFallback; };

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

  # Local clones of git repositories. Each is a string containing the path to a
  # working directory. These are useful for checks which aren't possible using
  # fetchgit, e.g. looking for unpushed commits or unstaged changes.
  localRepos = import (runCommand "git-repos.nix"
    {
      inherit findIgnoringPermissions HOME;
      cacheBuster = toString (currentTime / 3600);
    }
    ''
      function repos {
        for D in warbo-utilities System/Tests
        do
          D="$HOME/$D"
          [[ -e "$D" ]] || continue

          "$findIgnoringPermissions" "$D" -type d -name '.git' |
            grep -v '/\.asv/'
        done

        for D in "$HOME/Programming"/*
        do
          DIRNAME=$(basename "$D")
          [[ "x$DIRNAME" = "xgit-html" ]] && continue
          [[ "x$DIRNAME" = "xNotMine"  ]] && continue
          [[ "x$DIRNAME" = "xrepos"    ]] && continue
          "$findIgnoringPermissions" "$D" -type d -name '.git' |
            grep -v '/\.asv/'
        done
      }

      function entries {
        while read -r REPO
        do
          DIR=$(dirname "$REPO")
          NAME=$(basename "$DIR")
          HASH=$(echo "$DIR" | sha256sum | cut -d ' ' -f1)
          echo "\"$HASH-$NAME\" = \"$DIR\";"
        done < <(repos)
      }

      echo '{'   > "$out"
        entries >> "$out"
      echo '}'  >> "$out"
    '');

  myRepos = import (runCommand "my-repos.nix" { inherit HOME; } ''
    shopt -s nullglob

    echo '{' > "$out"
      for D in "$HOME"/Programming/repos/*.git
      do
        NAME=$(basename "$D" .git)
        HASH=$(echo "$D" | sha256sum | cut -d ' ' -f1)
        echo "\"$HASH-$NAME\" = \"$D\";" >> "$out"
      done
    echo '}' >> "$out"
  '');

  myReposUnhashed =
    with {
      stripHash = s: concatStrings (tail (dropWhile (c: c != "-")
                                                    (stringToCharacters s)));
    };
    mapAttrs' (name: value: {
                inherit value;
                name = stripHash name;
              })
              myRepos;

  myHaskellRepos = filterAttrs (n: _: elem n (attrNames myHaskell))
                               myReposUnhashed;

  cacheRepo =
    with {
      cache   = "/tmp/general-tests-cache/git-repos";
      failCmd = "${fail}/bin/fail";
    };
    ''
      # Create a '${cache}/$pkgName' directory by cloning '$repo', then 'pushd'
      # into it. We hard-code the binaries we use so we're more self-contained.

      set -e
      [[ -n "$pkgName" ]] || "${failCmd}" "No 'pkgName' env var found"
      [[ -n "$repo"    ]] || "${failCmd}" "No 'repo' env var found"

      [[ -d "${cache}/$pkgName" ]] || {
        echo "Repo '${cache}/$pkgName' not found, cloning..." 1>&2
        mkdir -p "${cache}"
        "${git}/bin/git" clone "$repo" "${cache}/$pkgName" ||
          "${failCmd}" "Failed to clone '$repo'"
        chmod a+w -R "${cache}/$pkgName"
      }

      pushd "${cache}/$pkgName" ||
        "${failCmd}" "Couldn't cd to '${cache}/$pkgName'"

      git pull --all || true  # Ignore network failures
    '';

  initHaskellTest = ''
    ${cacheRepo}

    # Make a clean slate
    rm -rf dist dist-newstyle
    rm -f cabal.project.local

    # If we have extra options like external sources, put them in place now
    [[ -z "$extra" ]] || {
      cp -v "$extra" cabal.project.local
      chmod a+w -R cabal.project.local
    }
  '';
}
