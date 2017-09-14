args:

with rec {
  pkgs    = import ./helpers/nix-config.nix args;
  helpers = pkgs.callPackage ./helpers {};
};
with pkgs.lib;
with builtins;

listToAttrs (map (f: {
                   name  = removeSuffix ".nix" f;
                   value = import (./tests + "/${f}") { inherit helpers pkgs; };
                 })
                 (attrNames (readDir ./tests)))
