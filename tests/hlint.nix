{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash findutils gnused haskellPackages jq latestGit runCommand sanitiseName
    stdenv;
  inherit (helpers)
    haskellSources;
};

rec {

getProjects = stdenv.mkDerivation {
  name         = "projects";
  buildInputs  = [ findutils gnused jq ];
  buildCommand = ''
    shopt -s nullglob
    echo "[" >> "$out"

    if [[ -d /home/chris/Programming ]]
    then
      # Standalone Haskell files
      #DIR="/home/chris/Programming/Haskell/"
      #echo "$DIR"*.hs
      #echo "$DIR"*.lhs
      true
      # Project directories
      #LOCATE_PATH=/var/cache/locatedb "$../helpers/my_haskell.sh"    |
      #  grep -v "/Haskell/quickcheck$" |
      #  grep -v "/Haskell/imm$"        |
      #  grep -v "/Haskell/ifcxt$"
    else
      echo "No projects on disk" 1>&2
    fi
    echo "]" >> "$out"
  '';
};

projects = import "${getProjects}";

testCommand = ''
  hlint -XNoCPP "--ignore=Parse error" "$src" && echo "Passed" > "$out"
'';

mkTest = src: stdenv.mkDerivation {
  inherit src;
  name         = "hlint-test";
  buildInputs  = [ haskellPackages.hlint ];
  buildCommand = testCommand;
};

testRepo = src:
  stdenv.mkDerivation {
    inherit src;
    name         = "test-repo";
    buildInputs  = [ haskellPackages.hlint ];
    buildCommand = testCommand;
  };

test = stdenv.mkDerivation {
  name         = "hlint-tests";
  buildInputs  = (map mkTest projects) ++ (map testRepo haskellSources);
  buildCommand = ''echo "Passed" > "$out"'';
};

}
