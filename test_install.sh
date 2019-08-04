#! /bin/bash

# Copyright (c) 2019 Filippo Ranza <filipporanza@gmail.com>

python3 sudo install.py -c 

for script in *zsh; do
    local NAME=$(echo "$script" | perl -pe 's|.+\.(\w+)|$1|')
    which "$NAME" || exit 1
done
