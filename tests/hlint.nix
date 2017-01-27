{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash findutils gnused haskellPackages jq runCommand sanitiseName stdenv;
};

rec {

getProjects = runCommand "projects"
  {
    buildInputs = [ findutils gnused jq ];
    LOCATE_PATH = getEnv "LOCATE_PATH";
  }
  ''
    #!${bash}/bin/bash
    shopt -s nullglob

    {
      # Standalone Haskell files
      DIR="~/Programming/Haskell/"
      echo "$DIR"*.hs
      echo "$DIR"*.lhs

      # Project directories
      "${../helpers/my_haskell.sh}"    |
        grep -v "/Haskell/quickcheck$" |
        grep -v "/Haskell/imm$"        |
        grep -v "/Haskell/ifcxt$"
    } | grep "^." | jq -R '.' | jq -s '.' > "$out"
  '';

projects = fromJSON (readFile "${getProjects}");

mkTest = project: stdenv.mkDerivation {
  name         = "hlint-test-${sanitiseName project}";
  buildInputs  = [ haskellPackages.hlint ];
  buildCommand = ''
    hlint -XNoCPP "--ignore=Parse error" "${project}" && echo "Passed" > "$out"
  '';
};

test = stdenv.mkDerivation {
  name         = "hlint-tests";
  buildInputs  = map mkTest projects;
  buildCommand = ''echo "Passed" > "$out"'';
};

}
