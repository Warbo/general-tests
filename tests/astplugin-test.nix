{ helpers, pkgs }:
with pkgs;
wrap {
  name   = "astplugin-test";
  paths  = [ bash fail ] ++ (withNix {}).buildInputs;
  vars   = withNix {
    DIR = helpers.HOME + "/Programming/Haskell/AstPlugin";
  };
  script = ''
    #!/usr/bin/env bash
    set -e

    cd "$DIR"         || fail "Failed to cd to '$DIR'"
    [[ -e test.nix ]] || fail "No test.nix in astplugin"
    nix-build --no-out-link --show-trace -E 'import ./test.nix' ||
      fail "Failed to build astplugin's test.nix"
  '';
}
