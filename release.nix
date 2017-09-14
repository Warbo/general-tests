with {
  args = {
    inherit (import <nixpkgs> { config = {}; }) fetchgit;
  };
};
{
  all   = import ./.         args;
  tests = import ./tests.nix args;
}
