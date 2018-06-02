{ pkgs ? import <nixpkgs> {}, helpers ? {} }:

with builtins;
with rec {
  inherit (pkgs)
    bash haskellPackages lib wrap;

  inherit (lib)
    mapAttrs;

  inherit (helpers)
    myHaskell;

  testRepo = name: src: wrap {
    name   = "hlint-${name}";
    paths  = [ bash haskellPackages.hlint ];
    vars   = { inherit src; };
    script = ''
      #!/usr/bin/env bash
      set -e
      hlint -XNoCPP "--ignore=Parse error" "$src"
    '';
  };
};

mapAttrs testRepo myHaskell
