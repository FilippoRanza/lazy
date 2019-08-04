#! /usr/bin/zsh

# Copyright (c) 2019 Filippo Ranza <filipporanza@gmail.com>


function die(){
    echo "$1"
    exit 1
}


function commit_push(){
    git commit -q -a -m "$1"
    git push -q "$2"
}

function get_default_remote(){
    local def_branch=$(git branch | awk '/*/ {print $2}')
    git config --get "branch.$def_branch.remote"
}


git status &> /dev/null || die "$0: This is not a git repository"


while [[ "$1" ]] ; do

    if [[ "$set_remote" ]] ; then
        local upstream="$1"
        unset set_remote
    else
        case "$1" in
            '-r'|'--remote')
                local set_remote='1'
                ;;
            *)
                MSG="$1"
                ;;
        esac
    fi
    shift
done


if [[ "$upstream" ]] ; then
    git remote show | grep "$upstream" &> '/dev/null' || die "$upstream is not a remote"
else
    upstream=$(get_default_remote)
fi


local commit_message=${MSG:-"commit $(date '+x%Y-%m-%d %H:%M')"}
commit_push "$commit_message" "$upstream" 
