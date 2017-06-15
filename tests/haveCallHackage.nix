#!/usr/bin/env bash

set -e

O=$(nix-instantiate --eval -E \
      '(import <nixpkgs> { config = _: {}; }).haskellPackages ? callHackage')

MSG="No callHackage when customisations are disabled"
[[ "x$O" = "xtrue" ]] || {
  echo "not ok - $MSG"
  exit 1
}
echo "ok - $MSG"

O=$(nix-instantiate --eval -E \
      '(import <nixpkgs> {}).haskellPackages ? callHackage')

MSG="No callHackage when customisations enabled"
[[ "x$O" = "xtrue" ]] || {
  echo "not ok - $MSG"
  exit 1
}
echo "ok - $MSG"
