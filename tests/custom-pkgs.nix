{ pkgs, helpers }:

with { src = helpers.inputFallback "nix-config"; };
import "${src}/release.nix"
