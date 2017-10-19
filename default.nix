{ nix-config ? null, nixpkgs ? null, packageOnly ? true }:

with rec {
  pkgs  = import ./helpers/nix-config.nix { inherit nix-config nixpkgs; };
  tests = import ./tests.nix              { inherit pkgs; };
  all   = with pkgs; withDeps (allDrvsIn tests) nothing;
};
if packageOnly
   then all
   else { inherit all tests; }
