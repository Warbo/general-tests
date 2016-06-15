pkgs: now: with pkgs; with builtins; with lib;

rec {

dir  = builtins.getEnv "HOME" + "/Programming/Haskell";

dirs = filter keep (map (d: dir + "/" + d)
                        (attrNames (readDir dir)));

keep = x: ! (any (re: match re x != null) [
              ".*/Haskell/quickcheck$"
              ".*/Haskell/imm$"
              ".*/Haskell/ifcxt$"
            ]);

hlintIn = d: scriptTest "hlint in ${d}" {
               env = { buildInputs = [ haskellPackages.hlint ]; };
               script = ''
                 # Timestamp ${toString now}
                 hlint -XNoCPP "--ignore=Parse error" "${d}"
               '';
             };

result = all hlintIn dirs;

}.result
