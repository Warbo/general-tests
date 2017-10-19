with builtins;
with (import <nixpkgs> {}).lib;
with rec {
  inherit (import ../. { packageOnly = false; }) tests;

  pathsFrom = prefix: x:
    if isDerivation x
       then [ prefix ]
       else if isAttrs x
               then concatLists
                      (attrValues
                        (mapAttrs (n: pathsFrom (prefix ++ [n])) x))
               else [];
};
toJSON (pathsFrom [] tests)
