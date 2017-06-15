#!/usr/bin/env bash

function fail {
    echo "$1" 1>&2
    exit 1
}

[[ -e ~/Writing/STP/sites/stp/2015/10/index.md ]] || fail "2015/10 has no index"
[[ -e ~/Writing/STP/talks/2015/10/slides.md ]]    || fail "2015/10 has no slides"
