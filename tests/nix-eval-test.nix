{ helpers, pkgs }:
helpers.notImplemented "nix-eval-test"

/*
#!/usr/bin/env bash

# nix-eval's test suite is empty if nix-shell isn't available, which is the case
# during installation. Hence to make sure the tests are running, we run them
# from the source directory

function testMsg {
    if [[ "$1" -eq 0 ]]
    then
        echo "ok - $2"
    else
        echo "not ok - $2"
        exit 1
    fi
}

function runTest {
  hsConfig
  testMsg "$?" "Configured with DIR=$DIR"

  ./test.sh
  testMsg "$?" "Tested with DIR=$DIR"
}

DIR=~/Programming/Haskell/nix-eval
pushd "$DIR" > /dev/null
testMsg "$?" "Entered '$DIR'"

runTest

popd > /dev/null

# We also clone the source and test that too, in case our copy is
# unrepresentative
DIR=$(mktemp -d -t 'nix-eval-test-XXXXX')
pushd "$DIR" > /dev/null
testMsg "$?" "Entered temp dir"

git clone http://chriswarbo.net/git/nix-eval.git nix-eval
testMsg "$?" "Cloned nix-eval"

pushd nix-eval > /dev/null
testMsg "$?" "Entered nix-eval clone"

runTest

popd > /dev/null
popd > /dev/null

rm -rf "$DIR"
*/
