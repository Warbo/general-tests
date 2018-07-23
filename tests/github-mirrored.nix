{ helpers, pkgs }:
with builtins;
with pkgs;
with lib;
with rec {
  dir   = "/home/chris/Programming/repos";
  dirs  = filter (hasSuffix ".git") (attrNames (readDir dir));
  check = entry: wrap {
    name   = "check-${entry}-is-on-github";
    paths  = [ git fail ];
    vars   = { REPO = "${dir}/${entry}"; };
    script = ''
      #!/usr/bin/env bash
      set -e

      cd "$REPO" || fail "Couldn't cd to '$REPO'"
      git remote | grep github > /dev/null ||
        fail "No GitHub mirrors for '$REPO'"
    '';
  };
};
if pathExists dir
   then genAttrs dirs check
   else trace "Warning: Path '${dir}' wasn't found, no repos to check" {}
