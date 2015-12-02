#!/usr/bin/env bash

./helpers/times.sh |
    nix-shell -p 'haskellPackages.ghcWithPackages (hs: [ hs.random ])' \
              --run './helpers/choose.hs'
