{ helpers, pkgs }:
with pkgs;
wrap {
  name  = "have-STP";
  paths = [ bash fail ];
  vars  = { dir = helpers.inputFallback "writing"; };
  script = ''
    #!/usr/bin/env bash
    set -e
    [[ -e "$dir/STP/sites/stp/2015/10/index.md" ]] || fail "Have no site"
    [[ -e "$dir/STP/talks/2015/10/slides.md"    ]] || fail "Have no slides"
  '';
}
