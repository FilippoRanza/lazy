#! /usr/bin/zsh

set -e


if [[ "$1" ]] ; then
    while [[ "$1" ]]; do
        okular "$1"*
        shift
    done
else 
    for f in *.pdf; do
        okular "$f"
    done
fi