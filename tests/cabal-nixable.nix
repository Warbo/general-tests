{ pkgs, helpers }:

with builtins;
with rec {
  inherit (helpers)
    allHaskell combineTests getGit haskellSources repoOf;

  inherit (pkgs)
    haskellPackages stdenv runCabal2nix;

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

combineTests "cabal-nixable" tests
