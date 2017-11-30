{
  pkgs    ? import ../helpers/nix-config.nix {},
  helpers ? import ../helpers/defs.nix
}:
with builtins;
with rec {
  inherit (pkgs)    haskell lib;
  inherit (lib)     mapAttrs;
  inherit (helpers) haskellTinced myHaskell;
};

#mapAttrs (_: repo: haskell.lib.doCheck (haskellTinced { inherit repo; }))
         myHaskell
