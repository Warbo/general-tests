{ nix-config ? null, nixpkgs ? null }:

with builtins;
with rec {
  pkgs       = if nixpkgs == null then <nixpkgs> else nixpkgs;
  local      = /home/chris/nix-config;
  remote     = (import pkgs { config = {}; }).fetchgit {
    url    = http://chriswarbo.net/git/nix-config.git;
    rev    = "d1b2b9b";
    sha256 = "1rsax2izq5083wlxssg0ch4bxkg2g1hm2v61vp8frg5v9q55rlgr";
  };
  config-src = if nix-config != null
                  then nix-config
                  else if pathExists local
                          then local
                          else (import remote {
                                 unstablePath = pkgs;
                               }).latestNixCfg;
};

import config-src { unstablePath = pkgs; }
