{ helpers ? pkgs.callPackage ../helpers {}, pkgs ? import <nixpkgs> {} }:

with builtins;
with pkgs;
with lib;
with rec {
  nested = listToAttrs (map (f: {
                              name  = removeSuffix ".nix" f;
                              value = import (./. + "/${f}") {
                                inherit helpers pkgs;
                              };
                            })
                            (filter (n: n != "default.nix")
                                    (attrNames (readDir ./.))));

  nameAll = path: x:
    if isDerivation x
       then x
       else if isAttrs x
               then mapAttrs' (n: v:
                                with { path' = path ++ [ n ]; };
                                {
                                  name  = concatStringsSep "." path';
                                  value = nameAll path' v;
                                })
                              x
               else null;

  drvsOf = n: x:
    if x == null
       then {}
       else if isDerivation x
               then { "${n}" = x; }
               else if isAttrs x
                       then fold (m: rest: rest // drvsOf m (getAttr m x))
                                 {}
                                 (attrNames x)
                       else abort "Unexpected value for ${n}";
};
drvsOf "DUMMY" (nameAll [] nested)
