{ helpers, pkgs }:

with builtins;
with pkgs;
with lib;
with rec {
  repoConfigs = import (runCommand "git-repo-configs.nix"
    { inherit (helpers) HOME; }
    ''
      # Find .git/config files
      function files {
        for D in .dotfiles .emacs.d Backups/OldCode Programming \
                 warbo-utilities Writing
        do
          [[ -e "$HOME/$D" ]] || continue
          echo "Looking for git repos in $HOME/$D" 1>&2
          "${helpers.findIgnoringPermissions}" "$HOME/$D" -type f -name config |
            grep    "/.git"     |
            grep -v "/git-html"
        done
      }

      echo '[' > "$out"
        while read -r F
        do
          echo "\"$F\"" >> "$out"
        done < <(files)
      echo ']' >> "$out"
    '');

  getUrls = wrap {
    name   = "getUrls";
    paths  = [ bash ];
    vars   = {
      configs = writeScript "repo-configs.txt"
                            (concatStringsSep "\n" repoConfigs);
    };
    script = ''
      #!/usr/bin/env bash
      set -e

      # Find URLs mentioned in a .git/config file
      ${concatStringsSep "\n"
          (map (cfg: ''
                 if [[ -e "${cfg}" ]]
                 then
                   while read -r REMOTE
                   do
                     echo "${cfg}	$REMOTE"
                   done < <(grep "^\s*url\s*=" < "${cfg}")
                 fi
               '')
               repoConfigs)}
    '';
  };

  remote = cfg: wrap {
    name   = "check-remote-repo-${sanitiseName cfg}";
    vars   = { inherit cfg; };
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
      done < <("${getUrls}")
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
    vars   = { inherit getUrls repo; };
    script = ''
      #!/usr/bin/env bash

      # Check that $repo is a remote of some local repo
      shopt -s nullglob
      URLS=$("$getUrls")

      echo "Looking for a source of '$repo'"
      echo "$URLS" | cut -f 2 | grep "$repo" > /dev/null || {
        echo "No source found for '$repo'" 1>&2
        exit 1
      }
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
