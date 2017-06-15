#!/usr/bin/env bash

nix-shell -p haskellPackages.runtime-arbitrary-tests --run runtime-arbitrary-tests
