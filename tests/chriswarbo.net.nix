{ helpers, pkgs }:

with rec {
  src = helpers.inputFallback "chriswarbo-net";
  all = import "${src}";
};
all.tests
