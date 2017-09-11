{ helpers, pkgs }:
with pkgs;
with {
  NIX_EVAL_HASKELL_PKGS = writeScript "ghc7.10-for-nix-eval.nix" ''
    (import <nixpkgs> {}).haskell.packages.ghc7103
  '';

  run = extraEnv: runCommand "runtime-arbitrary-tests"
                    (withNix {
                      buildInputs = [ haskellPackages.runtime-arbitrary-tests ];
                    } // extraEnv)
                    ''
                      runtime-arbitrary-tests && echo "Pass" > "$out"
                    '';
};
{
  ghc7103 = run { inherit NIX_EVAL_HASKELL_PKGS; };

  haskellPackages = isBroken (run {});
}
