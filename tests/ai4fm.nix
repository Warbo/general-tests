{ helpers, pkgs }:
with pkgs;
runCommand "ai4fm"
  {
    buildInputs = [ fail ];
    writing     = latestGit { url = http://chriswarbo.net/git/writing.git; };
  }
  ''
    set -e
    cd "$writing/AI4FM" || fail "No AI4FM dir"

    for F in article.tex slides.md
    do
      [[ -e "$F" ]] || fail "No $F"
    done

    echo pass > "$out"
  ''
