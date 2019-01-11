{ helpers, pkgs }:
with pkgs;
wrap {
  name  = "emacs";
  paths = [ aspell aspellDicts.en emacs ];
  vars  = { cfg = latestGit { url = helpers.repoOf "warbo-emacs-d"; }; };
  script = ''
    #!/usr/bin/env bash
    set -e

    # Work in a temp dir for reliability and to avoid polluting real home dirs
    D=$(mktemp --tmpdir -d 'general-tests-emacs-XXXXX')

    function cleanup {
      # We use the innocuous name D, since deleting $HOME could go badly wrong!
      rm -rf "$D"
    }
    trap cleanup EXIT

    cp -r "$cfg" "$D/.emacs.d"
    chmod +w -R "$D/.emacs.d"
    HOME="$D" "$D/.emacs.d/test-runner.sh"
  '';
}
