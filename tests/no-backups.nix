{ helpers, pkgs }:

pkgs.wrap {
  name   = "no-backups";
  vars   = { inherit (helpers) HOME; };
  script = ''
    #!/usr/bin/env bash

    if [[ -z "$FULL" ]]
    then
      FULL=0
      echo "Set env var 'FULL' to keep going after a failure" 1>&2
    fi

    function backups {
      for D in "$HOME"/Programming/*
      do
        NAME=$(basename "$D")
        [[ "x$NAME" = "xgit-html" ]] && continue
        [[ "x$NAME" = "xNotMine"  ]] && continue
        echo "Looking for backups in '$D'" 1>&2
        find "$D" -type f -name '*~' -o -name '#*#' -o -name '.#*'
      done
    }

    ERR=0
    while read -r BACKUP
    do
        echo "$BACKUP looks like a backup file" 1>&2
        ERR=1
        if [[ "$FULL" -eq 0 ]]
        then
          exit 1
        fi
    done < <(backups)

    exit "$ERR"
  '';
}
