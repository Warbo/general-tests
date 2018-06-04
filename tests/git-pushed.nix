{ helpers, pkgs }:

with builtins;
with pkgs;
with lib;
with {
  check = name: repo: wrap {
    name   = "git-pushed-${name}";
    paths  = [ bash fail git ];
    vars   = { inherit repo; };
    script = ''
      #!/usr/bin/env bash
      set -e

      function remotes {
          # We should always be pushing to origin and github; we don't enforce
          # anything else since they're case-by-case. For example, we might
          # have a read-only "upstream" for fetching, with pushes going via
          # pull requests from "github"
          git remote | grep -e '\(origin\|github\)'
      }

      function branches {
          git branch | cut -c 3- | grep -v '^('
      }

      function checkBranch {
          git ls-remote "$1" 2> /dev/null | cut -f 2 |
                                            grep -Fx "refs/heads/$2" ||
              fail "'$repo' branch '$BRANCH' not on remote '$1'"
      }

      function skip {
          grep -v "opencl-horde"          |
          grep -v "/Backups/"             |
          grep -v "/git-html"             |
          grep -v "/System/Programs"      |
          grep -v "/NotMine/"             |
          grep -v "/OldCode/"             |
          grep -v "/Marking/"             |
          grep -v "/haskell-te/packages/" |
          grep -v "\.stack"               |
          grep -v "/TheoryExplorationBenchmark/modules/"
      }

      function checkRemotes {
          # Look for unpushed commits and missing branches. `git status` also lists
          # unpushed commits but it doesn't work in bare repos
          while read -r REMOTE
          do
              checkBranches "$REMOTE"
          done < <(remotes)
      }

      function checkBranches {
          MISSINGBRANCHES=0
          while read -r BRANCH
          do
              checkBranch "$1" "$BRANCH" || MISSINGBRANCHES=1
          done < <(branches)
          return "$MISSINGBRANCHES"
      }

      [[ -e "$repo" ]] || { echo "Skipping non-existent '$repo'"; continue; }
      echo "Checking '$repo'" 1>&2

      pushd "$repo" > /dev/null

      # Skip repos with no remote
      [[ -z "$(git remote)" ]] && exit 0

      checkRemotes

      popd > /dev/null
    '';
  };
};
mapAttrs check (helpers.localRepos // helpers.myRepos)
