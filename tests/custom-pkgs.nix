{ pkgs, helpers }:

with builtins;
with rec {
  src = helpers.inputFallback "nix-config";
  all = import "${src}/test.nix";
};

all.tests
