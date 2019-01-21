{ helpers, pkgs }:
with pkgs;
wrap {
  name   = "panhandle-test";
  paths  = [ bash fail pandocPkgs ];
  script = ''
    #!/usr/bin/env bash
    set -e

    MARKDOWN="*foo*"
    echo "Got Markdown '$MARKDOWN'"

    JSON=$(echo "$MARKDOWN" | pandoc -f markdown -t json)
    echo "Got JSON '$JSON'"

    TICK='`'
    TICKS="$TICK""$TICK""$TICK"
    UNWRAP=$(printf '%s{.unwrap}\n%s\n%s' "$TICKS" "$JSON" "$TICKS")
    echo "Got unwrap '$UNWRAP'"

    HTML=$(echo "$UNWRAP" | pandoc --filter panhandle -f markdown -t html) ||
      fail "Failed to check JSON"

    echo "Got HTML '$HTML'"

    echo "$HTML" | grep '<em>foo</em>' ||
      fail "Didn't unwrap *foo* in '$HTML'" 1>&2

    echo "pass"
  '';
}
