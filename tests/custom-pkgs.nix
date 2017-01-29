{ pkgs, helpers }:

with builtins;
with rec {
  inherit (pkgs)
    bash jq latestGit stdenv;

  packages = stdenv.mkDerivation {
    name = "custom-packages";
    src  = latestGit {
      url = http://chriswarbo.net/git/nix-config.git;
    };
    buildInputs  = [ jq ];
    buildCommand = ''
      set -e
      echo "[" > "$out"
      {
        # "Local" is where we keep "regular" packages
        for FILE in "$src"/custom/local/*.nix
        do
          basename "$FILE" .nix
        done

        # "Imports" are usually special-cases
        for FILE in "$src"/custom/imports/*.nix
        do
          basename "$FILE" .nix
        done

        # Haskell packages need prefixing by the compiler version
        for FILE in "$src"/custom/haskell/*.nix
        do
          NAME=$(basename "$FILE" .nix)
          echo "haskellPackages.$NAME"
        done

        # One offs (usually overrides)
        for FILE in "$src"/custom/*.nix
        do
          BASE=$(basename "$FILE" .nix)
          [[ -d "$BASE" ]] || echo "$FILE"
        done
      } | jq -R '.' >> "$out"
      echo "]" >> "$out"
    '';
  };

  buildPkg = given:
    with { pkg = pkgs."${given}"; };
    stdenv.mkDerivation {
      name = "check-pkg";
      buildInputs = [(if typeOf pkg != "set"
                         then bash
                         else if pkg ? executable && pkg.executable
                                 then bash
                                 else if pkg ? src
                                         then pkg
                                         else if pkg ? buildCommand
                                                 then pkg
                                                 else bash)];
      buildCommand = ''touch "$out"'';
    };
};

stdenv.mkDerivation {
  name         = "custom-pkg-test";
  buildInputs  = map buildPkg (import "${packages}");
  buildCommand = ''touch "$out"'';
}
