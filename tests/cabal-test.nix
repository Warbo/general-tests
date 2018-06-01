{
  pkgs    ? import ../helpers/nix-config.nix {},
  helpers ? import ../helpers/defs.nix
}:
with builtins;
with rec {
  inherit (pkgs)    haskell lib;
  inherit (lib)     mapAttrs;
  inherit (helpers) haskellStandalone myHaskell;
};
with pkgs;
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
