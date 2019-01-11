{ helpers, pkgs }:

with builtins;
with pkgs;
with lib;
with rec {
  repoConfigs = import (runCommand "git-repo-configs.nix"
    { inherit (helpers) HOME; }
    ''
      # Find .git/config files
      function findInDir {
        [[ -e "$1" ]] || return
        echo "Looking for git repos in $1" 1>&2
        "${helpers.findIgnoringPermissions}" "$1" -type f -name config |
          grep "/.git"
      }

      function files {
        for D in .dotfiles .emacs.d Backups/OldCode warbo-utilities Writing
        do
          findInDir "$HOME/$D"
        done

        for D in "$HOME"/Programming/*
        do
          NAME=$(basename "$D")
          [[ "x$NAME" = "xgit-html" ]] ||
          [[ "x$NAME" = "xNotMine"  ]] || findInDir "$D"
        done
      }

      echo '[' > "$out"
        while read -r F
        do
          echo "\"$F\"" >> "$out"
        done < <(files)
      echo ']' >> "$out"
    '');

  repoUrls = runCommand "git-repo-urls.tsv"
    {
      configs = writeScript "repo-configs.txt"
                            (concatStringsSep "\n" repoConfigs);
    }
    ''
      # Find URLs mentioned in a .git/config file
      touch "$out"
      while read -r CFG
      do
        if [[ -e "$CFG" ]]
        then
          while read -r REMOTE
          do
            echo "$CFG	$REMOTE" >> "$out"
          done < <(grep "^\s*url\s*=" < "$CFG")
        fi
      done < "$configs"
    '';

  remote = cfg: wrap {
    name   = "check-remote-repo-${sanitiseName cfg}";
    vars   = { inherit cfg repoUrls; };
    script = ''
      #!/usr/bin/env bash
      set -e

      while read -r LINE
      do
        [[ -z "$LINE" ]] && continue

        CONF=$(echo "$LINE" | cut -f 1)
        [[ "x$CONF" = "x$cfg" ]] || continue

        URL=$(echo  "$LINE" | cut -f 2 | cut -d '=' -f 2 | sed -e 's@^\s*@@')
        if echo "$URL" | grep ':' > /dev/null
        then
          echo "Found remote '$URL'"

          # gitorious.org is no more
          echo "$URL" | grep "gitorious" > /dev/null && {
            echo "Reference to gitorious found in '$CONF'" 1>&2
            exit 1
          }
        else
          echo "Found local '$URL'"
          [[ -e "$URL" ]] || {
            echo "Remote '$URL' doesn't exist in '$CONF'" 1>&2
            exit 1
          }
        fi
      done < "$repoUrls"
    '';
  };

  localRepos = import (runCommand "local-repos.nix" {} ''
    echo '[' > "$out"
      for REPO in /home/chris/Programming/repos/*.git
      do
        echo "\"$REPO\"" >> "$out"
      done
    echo ']' >> "$out"
  '');

  local = repo: wrap {
    name   = "local-repo-${sanitiseName repo}";
    vars   = { inherit repo repoUrls; };
    script = ''
      #!/usr/bin/env bash

      # Check that $repo is a remote of some local repo
      echo "Looking for a source of '$repo'"
      if cut -f 2 < "$repoUrls" | grep "$repo" > /dev/null
      then
        exit 0
      fi

      echo "No source found for '$repo'" 1>&2
      exit 1
    '';
  };
};
{
  locals = listToAttrs (map (r: {
                              name  = baseNameOf r;
                              value = local r;
                            })
                            localRepos);

  remotes = listToAttrs (map (cfg: {
                               name  = sanitiseName cfg;
                               value = remote cfg;
                             })
                             repoConfigs);
}
