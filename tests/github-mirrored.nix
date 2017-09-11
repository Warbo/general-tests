{ helpers, pkgs }:
with pkgs;
runCommand "github-mirrored" { buildInputs = [ git fail ]; } ''
  set -e

  # Make sure everything in ~/Programming is version controlled
  UNMIRRORED=""
  for REPO in /home/chris/Programming/repos/*.git
  do
    pushd "$REPO" > /dev/null
    if ! git remote | grep github > /dev/null
    then
        UNMIRRORED="$UNMIRRORED $REPO"
    fi
    popd > /dev/null
  done

  [[ -z "$UNMIRRORED" ]] || fail "No GitHub mirrors for $UNMIRRORED"
  echo pass > "$out"
''
