{ nix-config ? null, nixpkgs ? null }:

with builtins;
with rec {
  bootPkgs   = config: import <nixpkgs> { inherit config; };
  bootConfig = (bootPkgs {}).fetchgit {
    url    = http://chriswarbo.net/git/nix-config.git;
    rev    = "d1b2b9b";
    sha256 = "1rsax2izq5083wlxssg0ch4bxkg2g1hm2v61vp8frg5v9q55rlgr";
  };
};

import (if nixpkgs == null then <nixpkgs> else nixpkgs) {
  config = if nix-config == null
              then with tryEval <nix-config>;
                   if success
                      then import "${value}/unstable.nix"
                      else with bootPkgs (import "${bootConfig}/config.nix");
                           latestNixCfg
              else import "${nix-config}/unstable.nix";
}
