{ pkgs, helpers }:

with builtins;
with rec {
  inherit (helpers)
    allHaskell haskellSources;

  inherit (pkgs)
    haskellPackages lib runCabal2nix stdenv;

  inherit (lib)
    mapAttrs;

  configurePkg = src:
    stdenv.mkDerivation {
      inherit src;
      name         = "configure-package";
      buildInputs  = [ haskellPackages.cabal-install haskellPackages.ghc
                       haskellPackages.happy ];
      buildCommand = ''
        set -e
        cp -r "$src" ./src
        chmod +w -R ./src
        cd ./src
        export HOME="$PWD"
        cabal update
        cabal sandbox init
        cabal install   --enable-tests --dependencies-only
        cabal configure --enable-tests
        cabal build
        touch "$out"
      '';
    };

  tests = mapAttrs (_: configurePkg) allHaskell;
};

tests
