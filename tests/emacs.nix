{ helpers, pkgs }:
helpers.notImplemented "emacs"/*
with pkgs;
runCommand "emacs"
  {
    CFG         = latestGit { url = helpers.repoOf "warbo-emacs-d"; };
    buildInputs = [ aspell aspellDicts.en emacs ];
  }
  ''
    export HOME="$PWD/home"
    mkdir "$HOME"
    cp -r "$CFG" "$HOME/.emacs.d"
    chmod +w -R "$HOME/.emacs.d"
    "$HOME/.emacs.d/test-runner.sh"
  ''
*/
