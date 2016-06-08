#!/usr/bin/env bash

cd ~/Writing/AI4FM || exit 1

for F in article.tex slides.md
do
    [[ -e "$F" ]] || { echo "No $F" 1>&2 ; exit 1; }
done
