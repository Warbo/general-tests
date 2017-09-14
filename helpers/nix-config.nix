{ fetchgit, nix-config ? null, nixpkgs ? null }:

with builtins;
with rec {
  chosenNixpkgs  = if nixpkgs == null then <nixpkgs> else nixpkgs;

  withConfig     = cfg: import chosenNixpkgs {
    config = import "${cfg}/config.nix";
  };

  configUrl      = http://chriswarbo.net/git/nix-config.git;

  fallbackConfig = fetchgit {
    url    = configUrl;
    rev    = "2cc683b";
    sha256 = "1xm2jvia4n002jrk055c3csy8qvyjw9h0vilxzss0rb8ik23rn9g";
  };

  latestConfig   = (withConfig fallbackConfig).latestGit {
    url = configUrl;
  };

  # Use nix-config argument, fall back to <nix-config>, fall back to latestGit
  chosenConfig   = if nix-config == null
                    then with tryEval <nix-config>;
                         if success
                            then value
                            else latestConfig
                    else nix-config;
};
withConfig chosenConfig
