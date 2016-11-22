#!/usr/bin/env bash
BASE=$(dirname "$(readlink -f "$0")")

echo "Looking up derivation for '$1'" 1>&2
# shellcheck disable=SC2016
DRV=$("$BASE"/tests.sh | jq -r --arg name "$1" '.[$name].drv')

echo "Realising '$DRV'" 1>&2
SCRIPT=$(nix-store --show-trace -r "$DRV")

echo "Running '$SCRIPT'" 1>&2
"$SCRIPT"
