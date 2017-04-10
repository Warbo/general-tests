{ pkgs ? import <nixpkgs> {} }:
with {
  inherit (pkgs)
    lib stdenv;
};
with lib;

stdenv.mkDerivation {
  name         = "tests";
  buildInputs  = map (t: t.test)
                     (attrValues (import ./tests.nix { inherit pkgs; }));
  buildCommand = ''
    echo "Passed" > "$out"
  '';
}
