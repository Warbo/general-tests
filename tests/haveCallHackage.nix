{ helpers, pkgs }:
helpers.notImplemented "have-call-hackage"/*
with pkgs;
with {
  boolToDrv = bool: runCommand "bool2drv" {} ''
    echo "foo" > "$out"
    exit ${if bool then "0" else "1"}
  '';
};
{
  noCallHackageWhenCustomisationsAreDisabled = boolToDrv
    ((import <nixpkgs> { config = _: {}; }).haskellPackages ? callHackage);

  haveCallHackageWhenCustomisationsEnabled = boolToDrv
    ((import <nixpkgs> {}).haskellPackages ? callHackage);
}
*/
