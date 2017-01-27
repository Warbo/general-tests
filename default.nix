# Many of our tests use custom Nix overrides, so we fetch those first.
with rec {
  # We need some version of nixpkgs in order to fetch git repos; use default
  pristinePkgs = import <nixpkgs> {};

  # Nixpkgs only lets us fetch a known git commit, so these overrides are old
  configUrl    = http://chriswarbo.net/git/nix-config.git;
  knownConfig  = pristinePkgs.fetchgit {
    url    = configUrl;
    rev    = "2a83e1bb0fcfd0dc293221812fbf4a03ed37f9f0";
    sha256 = "1jdsh7ysq6z1hx9z56qiypcazy8b0nhhgcykmxdfm4yy0lirspw2";
  };
  oldOverriddenPkgs = import <nixpkgs> {
                        config = import "${knownConfig}/config.nix";
                      };

  # Use the old overrides to get the latest version of the overrides
  config  = oldOverriddenPkgs.latestGit { url = configUrl; };
  newPkgs = import <nixpkgs> {
              config = import "${config}/config.nix";
            };
};
with newPkgs;
with lib;

stdenv.mkDerivation {
  name = "tests";
  src  = ./.;
  buildInputs  = map (t: t.test) (import ./tests.nix { pkgs = newPkgs; });
  buildCommand = ''
    echo "Passed" > "$out"
  '';
}
