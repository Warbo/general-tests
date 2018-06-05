{ pkgs, helpers }:
with builtins;
with pkgs;
with lib;
with helpers;
wrap {
  name  = "cabal-test";
  paths = [ bash ];
  /*vars = mapAttrs (_: repo:
                    with { pkg = haskellStandalone { inherit repo; }; };
                    if pkg ? override
                       then haskell.lib.doCheck pkg  # Probably a Haskell package
                       else pkg)                     # Probably a delayed failure
         myHaskell;*/
  script = ''
    #!/usr/bin/env bash
    exit 1
  '';
}
