{ pkgs ? import <nixpkgs> {} }:
with {
  inherit (pkgs)
    lib stdenv;
};
with lib;

stdenv.mkDerivation {
  name         = "tests";
  buildInputs  = attrValues (import ./tests.nix { pkgs = pkgs; });
  buildCommand = ''
    echo "Passed" > "$out"
  '';
}
