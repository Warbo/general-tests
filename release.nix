import ./tests.nix {
  pkgs = import <nixpkgs> { config = import <nix-config>; };
}
