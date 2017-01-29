# Many of our tests use custom Nix overrides, so we fetch those first.
with rec {
  # Loads nixpkgs with a particular config
  pkgsWith = config: import <nixpkgs> {
    config = import "${config}/config.nix";
  };

  # Use the default nixpkgs to fetch git repos
  pristinePkgs = import <nixpkgs> {};

  # We're limited to pre-specified git commits, so load one of our overrides
  configUrl         = http://chriswarbo.net/git/nix-config.git;
  oldOverriddenPkgs = pkgsWith (pristinePkgs.fetchgit {
    url    = configUrl;
    rev    = "2a83e1bb0fcfd0dc293221812fbf4a03ed37f9f0";
    sha256 = "1jdsh7ysq6z1hx9z56qiypcazy8b0nhhgcykmxdfm4yy0lirspw2";
  });

  # Use the old overrides to get the latest version of the overrides
  newPkgs = pkgsWith (oldOverriddenPkgs.latestGit { url = configUrl; });
};
with newPkgs;
with lib;

/*stdenv.mkDerivation {
  name         = "tests";
  buildInputs  = map (t: t.test) (import ./tests.nix { pkgs = newPkgs; });
  buildCommand = ''
    echo "Passed" > "$out"
  '';
}*/
newPkgs.bash
