with { pkgs = import ./nix-config.nix {}; };
pkgs.callPackage ./. {}
