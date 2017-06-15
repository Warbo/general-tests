with builtins;
with import <nixpkgs> {};
with lib;
with rec {
  tests = import ../tests.nix {};

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
