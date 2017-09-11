{ helpers, pkgs }:
with pkgs;
with rec {
  src = helpers.inputFallback "theory-exploration-benchmarks";
  pkg = import "${src}" {};
};
pkg.fullToolTest
