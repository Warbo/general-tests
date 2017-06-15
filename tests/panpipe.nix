{ pkgs, helpers }:

with pkgs;
{
  panpipeWorks = buildEnv {
    name = "env-with-panpipe";
    paths = [ panpipe ];
  };

  allContainsPanpipe = runCommand "all-contains-panpipe"
    { buildInputs = [ pkgs.all ]; }
    ''
      command -v panpipe && echo "pass" > "$out"
    '';
}
