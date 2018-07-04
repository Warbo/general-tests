{ nix-config ? null, nixpkgs ? null }:

with builtins;
with rec {
  pkgs  = if nixpkgs == null then <nixpkgs> else nixpkgs;
  local = /home/chris/Programming/Nix/nix-config;
  repo  = (import pkgs {}).fetchgit {
    url    = http://chriswarbo.net/git/nix-config.git;
    rev    = "f5bf5f0";
    sha256 = "1f3n5fgrqpxk3mnmpp1srrcbldasi44ymknl3y6hmrid8jigjnx0";
  };
  withCfg = cfg: import pkgs {
    overlays = import "${cfg}/overlays.nix";
  };
};

if nix-config != null
   then withCfg nix-config  # Use what we're given
   else if pathExists local
           then withCfg local  # Might be newer than HEAD; also works offline
           else (withCfg repo).withLatestCfg pkgs  # Bootstrap to HEAD
