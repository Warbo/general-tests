pkgs: with pkgs; with builtins; with lib;

rec {

dir  = builtins.getEnv "HOME" + "/Programming/Haskell";

dirs = map (d: dir + "/" + d)
           (attrNames (readDir dir));

hlintIn = d: scriptTest {
            env = { buildInputs = [ haskellPackages.hlint ]; };
            script = ''
                hlint -XNoCPP "--ignore=Parse error" "${d}"
              '';
          };

results = listToAttrs (map (d: { name = "hlint in d"; value = hlintIn d; })
                           dirs);

}
