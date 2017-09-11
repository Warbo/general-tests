{ pkgs ? import <nixpkgs> {} }:
with builtins;
with pkgs;
with lib;
with { helpers = callPackage ./helpers {}; };

listToAttrs (map (f: {
                   name  = removeSuffix ".nix" f;
                   value = import (./tests + "/${f}") { inherit helpers pkgs; };
                 })
                 (attrNames (readDir ./tests)))
