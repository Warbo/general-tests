{ pkgs, helpers }:

with builtins;
with rec {
  inherit (pkgs)
    bash jq latestGit lib stdenv;

  inherit (lib)
    attrByPath splitString;

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
          [[ -d "$src/custom/$BASE" ]] || echo "$BASE"
        done
      } | jq -R '.' >> "$out"
      echo "]" >> "$out"
    '';
  };

  buildPkg = given:
    with rec {
      # Look up attribute in pkgs
      found = attrByPath (splitString "." given)
                         (abort "Couldn't find ${given}")
                         pkgs;

      # If we found a package, use it; otherwise use nothing
      deps  = if typeOf found != "set"
                 then []  # Packages must be sets
                 else if found ? "bash"
                      then []  # Don't build the whole of nixpkgs
                      else if found ? executable && found.executable
                           then []  # Probably a script
                           else if found ? src
                                then [ found ]  # Probably a package
                                else if found ? buildCommand
                                        then [ found ]  # Probably a package
                                        else [];        # Probably not a package
    };
    trace given stdenv.mkDerivation {
      name         = "check-pkg";
      buildInputs  = deps;
      buildCommand = ''touch "$out"'';
    };
};

stdenv.mkDerivation {
  name         = "custom-pkg-test";
  buildInputs  = map buildPkg (import "${packages}");
  buildCommand = ''touch "$out"'';
}
