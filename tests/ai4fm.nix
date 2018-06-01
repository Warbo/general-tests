{ helpers, pkgs }:
with pkgs;
wrap {
  name   = "ai4fm";
  paths  = [ bash fail ];
  script = ''
    #!/usr/bin/env bash
    set -e
    cd ~/Writing/AI4FM || fail "No AI4FM dir"

    for F in article.tex slides.md
    do
      [[ -e "$F" ]] || fail "No $F"
    done
  '';
}
