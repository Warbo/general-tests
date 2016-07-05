with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "tests";
  src  = ./.;
  buildInputs = [
    bazaar
    darcs
    gnumake
    haskellPackages.hlint
    haskellPackages.ShellCheck
    mercurial
    #subversionClient
    which
    xidel
  ];
}
