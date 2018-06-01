{ helpers, pkgs }:
with pkgs;
wrap {
  name   = "astplugin-test";
  vars   = {};
  script = ''
    #!/usr/bin/env bash
    exit 1
  '';
}

/*
#!/usr/bin/env bash
set -e

function fail {
    echo "FAIL: $1" 1>&2
    exit 1
}

DIR=~/Programming/Haskell/AstPlugin
cd "$DIR"
if [[ -d "dist" ]]
then
    rm -r dist
fi
nix-build --show-trace -E 'import ./test.nix'
*/
