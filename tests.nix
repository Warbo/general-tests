{ pkgs ? import <nixpkgs> {} }:
with builtins;

with rec {
  # Use this for helper functions, etc. common to many tests
  helpers = rec {
    haskellRepos = [
    ];
  };
};
map (n: import (./tests + "/${n}") { inherit helpers pkgs; })
    (attrNames (readDir ./tests))
