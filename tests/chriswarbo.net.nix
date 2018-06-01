{ helpers, pkgs }:

with rec {
  src = helpers.inputFallback "chriswarbo-net";
  all = import "${src}";
};
pkgs.wrap { name = "dummy"; script = ''
  #!/usr/bin/env bash
  exit 1
''; }
#all.tests
