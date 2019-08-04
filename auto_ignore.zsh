#! /usr/bin/zsh

# Copyright (c) 2019 Filippo Ranza <filipporanza@gmail.com>


IGNORE='.gitignore'

function die(){
    echo "$1"
    exit 1
}


function init_ignore(){
    if [[ ! (-f "$IGNORE") ]] ; then
        echo "# .gitignore automatically created on $(date '+%Y-%m-%d %H:%M')" > "$IGNORE" 
        git add "$IGNORE" 
    fi
}


function get_untracked(){
    git status -s | 
    awk '/??/ {print $2}' 
}


function add_untracked(){
    tmp=$(get_untracked)
    if [[ "$tmp" ]] ; then
        echo "# adding untracked files on $(date '+%Y-%m-%d %H:%M')" >> "$IGNORE"
        echo "$tmp" >> "$IGNORE"
        git add "$IGNORE" 
        git commit -q -a -m 'automatically ignored untracked files'
    fi 
}



git status &> /dev/null || die 'This is not a git repository'

while [[ "$1" ]] ; do
    case "$1" in
        'l'|'local')
            _local_=1
        ;;
        *)
            die "$0: $1 unknown option"
        ;;
    esac
    shift
done

[[ "$_local_" ]] || cd $(git rev-parse --show-toplevel)

init_ignore
add_untracked
