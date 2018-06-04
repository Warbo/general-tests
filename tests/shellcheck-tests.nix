{ helpers, pkgs }:
with pkgs;
with lib;
with {
  check = name: shellScript: wrap {
    name   = "shellcheck-test-${name}";
    paths  = [ bash fail shellcheck ];
    vars   = { REAL_HOME = "/home/chris"; inherit shellScript; };
    script = ''
      #!/usr/bin/env bash
      set -e
      shopt -s nullglob

      [[ -e "$REAL_HOME" ]] && export HOME="$REAL_HOME"

      [[ -f "$shellScript" ]] || fail "Script '$shellScript' wasn't not found"
      echo "Checking '$shellScript'" 1>&2
      if shellcheck -e SC1091 -e SC1008 -e SC2001 -e SC2029 "$shellScript"
      then
        echo "Passed: '$shellScript'" 1>&2
      else
        fail "Failed: '$shellScript'" 1>&2
      fi
    '';
  };
};
mapAttrs check helpers.myShellscripts
