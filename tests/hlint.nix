with import <nixpkgs> {};
with builtins;

let
  getProjects = runCommand "projects"
    {
      buildInputs = [ findutils gnused ];
      LOCATE_PATH = getEnv "LOCATE_PATH";
    }
    ''
      #!{$bash}/bin/bash
      shopt -s nullglob

      function hs {
        echo "["

        # Standalone Haskell files
        DIR="~/Programming/Haskell/"
        echo "$DIR"*.hs
        echo "$DIR"*.lhs

        # Project directories
        "${../helpers/my_haskell.sh}"     |
          grep -v "/Haskell/quickcheck$"  |
          grep -v "/Haskell/imm$"         |
          grep -v "/Haskell/ifcxt$"

        echo "]"
      }

      hs > "$out"
    '';

  projects = import "${getProjects}";

  mkTest = name: {
    name = toString name;
    value = writeScript "hlint" ''
      #!${bash}/bin/bash
      hlint -XNoCPP "--ignore=Parse error" "${name}"
    '';
  };

in listToAttrs (map mkTest projects)
