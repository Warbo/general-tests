{ pkgs, helpers }:

with rec {
  inherit (helpers)
    haskellSources;

  inherit (pkgs)
    haskellPackages stdenv;

  configurePkg = src:
    stdenv.mkDerivation {
      inherit src;
      name         = "configure-package";
      buildInputs  = [ haskellPackages.cabal-install haskellPackages.ghc ];
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
};
stdenv.mkDerivation {
  name         = "cabal-nixable";
  buildInputs  = map configurePkg haskellSources;
  buildCommand = ''touch "$out"'';
}
