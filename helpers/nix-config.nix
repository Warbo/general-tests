{ fetchgit, nix-config ? null, nixpkgs ? null }:

with builtins;
with rec {
  inherit (withConfig fallbackConfig) latestGit;

  chosenNixpkgs  = if nixpkgs == null then <nixpkgs> else nixpkgs;

  withConfig     = cfg: import chosenNixpkgs {
    config = import "${cfg}/config.nix";
  };

  configUrl      = http://chriswarbo.net/git/nix-config.git;

  givenConfig    = if nix-config == null then [] else [ nix-config ];

  pathConfig     = with tryEval <nix-config>;
                   if success then [ value ] else [];

  fallbackConfig = fetchgit {
    url    = configUrl;
    rev    = "2cc683b";
    sha256 = "1xm2jvia4n002jrk055c3csy8qvyjw9h0vilxzss0rb8ik23rn9g";
  };

  latestConfig   = [ (latestGit { url = configUrl; }) ];

  envConfig      = with { v = getEnv "GIT_REPO_DIR"; };
                   if v == ""
                      then []
                      else [ (latestGit { url = v + "/nix-config.git"; }) ];

  devConfig      = with { v = getEnv "NIX_CONFIG"; };
                   if v == "" then [] else [ (trace "nix-config is ${v}" v) ];

  chosenConfig   = head (devConfig ++ givenConfig ++ pathConfig ++ envConfig ++
                         latestConfig);
};
withConfig chosenConfig
