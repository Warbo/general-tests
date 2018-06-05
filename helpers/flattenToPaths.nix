{ lib }:
with builtins;
with lib;
with rec {
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

  compose = f: g: x: f (g x);
};
compose (drvsOf "DUMMY") (nameAll [])
