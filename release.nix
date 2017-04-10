with builtins;
with rec {
  getPath = name: foldl' (result: this: if this.prefix == name
                                           then this.path
                                           else result)
                         null
                         nixPath;

  configUrl = "http://chriswarbo.net/git/nix-config.git";

  fixed = with import <nixpkgs> {};
          fetchgit {
            url    = configUrl;
            rev    = "ffa6543";
            sha256 = "08hi2j38sy89sk5aildja453yyichm2jna8rxk4ad44h0m2wy47n";
          };

  latest = with import <nixpkgs> { config = import "${fixed}/config.nix"; };
           latestGit { url = configUrl; };

  config = if getPath "nix-config" == null
              then latest
              else getPath "nix-config";
};
import ./tests.nix {
  pkgs = import <nixpkgs> { config = import "${config}/config.nix"; };
}
