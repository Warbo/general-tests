{ helpers, pkgs }:
with pkgs;
runCommand "panhandle" {} ''
  #!/usr/bin/env bash
  set -e

  echo "Checking for panhandle binary"
  nix-shell --show-trace -p panhandle -p which --run 'which panhandle' || {
    echo "panhandle binary not installed" 1>&2
    exit 1
  }

  MARKDOWN="*foo*"
  echo "Got Markdown '$MARKDOWN'"

  JSON=$(echo "$MARKDOWN" | nix-shell -p pandoc --run "pandoc -f markdown -t json")
  echo "Got JSON '$JSON'"

  TICK='`'
  TICKS="$TICK""$TICK""$TICK"
  UNWRAP=$(printf '%s{.unwrap}\n%s\n%s' "$TICKS" "$JSON" "$TICKS")
  echo "Got unwrap '$UNWRAP'"

  HTML=$(echo "$UNWRAP" | nix-shell -p pandoc -p panhandle --run \
           "pandoc --filter panhandle -f markdown -t html") || {
    echo "Failed to check JSON" 1>&2
    exit 1
  }
  echo "Got HTML '$HTML'"

  echo "$HTML" | grep '<em>foo</em>' || {
    echo "Didn't unwrap *foo* in '$HTML'" 1>&2
    exit 1
  }

  echo "pass" > "$out"
''
