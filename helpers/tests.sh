#!/usr/bin/env bash
cd "$(dirname $(readlink -f "$0"))"
nix-instantiate --json --read-write-mode --strict --eval tests.nix
