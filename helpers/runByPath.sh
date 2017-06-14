#!/usr/bin/env bash

cd "$(dirname "$(dirname "$(readlink -f "$0")")")"

# Take in an attribute path as JSON, e.g. '["a-test", "some-attr"]', look it up
# in tests.nix, e.g. '(import ./tests.nix {}).a-test.some-attr', and build it.

PTH=$(cat)
nix-build --show-trace --no-out-link --argstr path "$PTH" \
          -E '{ path }:
              with import <nixpkgs> {};
              with lib;
              with builtins;
              attrByPath (fromJSON path)
                         (error (toJSON { inherit path; }))
                         (import ./tests.nix {})'
