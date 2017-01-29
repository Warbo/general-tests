{ pkgs ? import <nixpkgs> {} }:
with {
  inherit (pkgs)
    stdenv;
};

stdenv.mkDerivation {
  name         = "tests";
  buildInputs  = map (t: t.test) (import ./tests.nix { pkgs = pkgs; });
  buildCommand = ''
    echo "Passed" > "$out"
  '';
}
