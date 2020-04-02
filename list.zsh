#! /bin/zsh

NAME=$(basename $0)
if [[ -z "$1" ]] ; then
    echo "$NAME: need an input file"
    exit 1
fi

if [[ -e "$1" ]] ; then
    FILE="$1"
elif which "$1" &> /dev/null; then
    FILE=$(which "$1")
else 
    echo "$NAME: $1 does not exist in $PWD neither in PATH"
    exit 1
fi


if file "$FILE" | grep 'text' &> /dev/null ; then
    source-highlight -i "$FILE" -f esc256 | less -R
else
    echo "$NAME: $FILE exists but it's not a text file"
    exit 1
fi