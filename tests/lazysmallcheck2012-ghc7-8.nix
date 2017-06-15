#!/usr/bin/env bash
nix-shell --run "true" -p 'haskell.packages.ghc784.lazysmallcheck2012'
