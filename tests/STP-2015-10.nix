{ helpers, pkgs }:
helpers.notImplemented "stp-2015-10"/*
with pkgs;

runCommand "have-STP"
  {
    buildInputs = [ fail ];
    dir         = helpers.inputFallback "writing";
  }
  ''
    [[ -e "$dir/STP/sites/stp/2015/10/index.md" ]] || fail "Have no site"
    [[ -e "$dir/STP/talks/2015/10/slides.md"    ]] || fail "Have no slides"
    echo pass > "$out"
  ''
*/
