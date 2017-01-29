{ pkgs ? import <nixpkgs> {}, helpers ? {} }:
with builtins;
with {
  inherit (pkgs)
    bash findutils gnused haskellPackages jq latestGit runCommand sanitiseName
    stdenv;
  inherit (helpers)
    haskellRepos;
};

rec {

getProjects = stdenv.mkDerivation {
  name         = "projects";
  buildInputs  = [ findutils gnused jq ];
  buildCommand = ''
    echo '[]' > "$out"
    exit 0
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
  name         = "hlint-test-${sanitiseName src}";
  buildInputs  = [ haskellPackages.hlint ];
  buildCommand = testCommand;
};

testRepo = url:
  stdenv.mkDerivation {
    name         = "test-repo";
    src          = latestGit { inherit url; };
    buildInputs  = [ haskellPackages.hlint ];
    buildCommand = testCommand;
  };

test = stdenv.mkDerivation {
  name         = "hlint-tests";
  buildInputs  = (map mkTest projects) ++ (map testRepo haskellRepos);
  buildCommand = ''echo "Passed" > "$out"'';
};

}
