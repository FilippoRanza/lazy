#! /bin/bash

# Copyright (c) 2019 Filippo Ranza <filipporanza@gmail.com>

sudo python3 install.py -c 

for script in *zsh; do
    NAME=$(echo "$script" | perl -pe 's|.+\.(\w+)|$1|')
    which "$NAME" || exit 1
done
