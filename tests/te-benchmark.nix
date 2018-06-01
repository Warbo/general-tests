{ helpers, pkgs }:
helpers.notImplemented "te-benchmark"/*
with pkgs;
with rec {
  src = helpers.inputFallback "theory-exploration-benchmarks";
  pkg = import "${src}" {};
};
pkg.tools
*/
