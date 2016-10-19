#!/usr/bin/env bash
./helpers/tests.sh | jq -r 'keys | join(' ')'
