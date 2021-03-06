{ helpers, pkgs }:
helpers.notImplemented "nix-eval-custom.sh"

        /*
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p hydra

set -e

cd ~/.nixpkgs

PKG_PATH=$(nix-instantiate --eval -E "<nixpkgs>")

GC="/nix/var/nix/gcroots/per-user/$USER"

hydra-eval-jobs              \
    "$PWD/release.nix"       \
    --gc-roots-dir "$GC"     \
    -j 1                     \
    --show-trace             \
    -I "haskell-te-src=$PWD" \
    -I "nixpkgs=$PKG_PATH"
*/
