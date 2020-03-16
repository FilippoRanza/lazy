#! /usr/bin/zsh

# Copyright (c) 2019-2020 Filippo Ranza <filipporanza@gmail.com>


set -e

__SETTINGS_FILE__='.run_settings.zsh'

__NAME__="${(%):-%N}"
function die() {
    echo "$__NAME__ : $1"
    exit 1
}

function load_settings(){
    if [[ -f "$__SETTINGS_FILE__" ]] ; then
        source "$__SETTINGS_FILE__"
    elif git status &> '/dev/null' ; then
        local prev=$(pwd)
        cd $(git rev-parse --show-toplevel)
        for conf in $(find . | grep "$__SETTINGS_FILE__") ; do
            cd $(dirname "$conf")
            source $(basename "$conf")
            cd -
        done
        cd "$prev"
    fi
}

function get_base_name() {
    echo "$1" | perl -pe 's|(\..+)||'
}

function run_latex() {
    # run twice, to generate the index
    pdflatex -synctex=1 -interaction=nonstopmode --shell-escape "$1"
    pdflatex -synctex=1 -interaction=nonstopmode --shell-escape "$1"
}

function run_c(){
   local name=$(get_base_name $1)
    gcc -g -Wall -Wpedantic -o "$name" "$1"
    shift
    "./$name" "$@"
}

function run_cpp() {
    die "$0 is not implemented"
}

function run_go() {
    die "$0 is not implemented"
}

function run_rust() {
    if [[ -e 'Cargo.toml' ]] ; then
        cargo run
    else
        local src="$1"
        local name=$(echo "$src" |  perl -pe 's|(.+)\..+|$1|')
        shift

        rustc "$src"
        ./"$name" "$@"
    fi
}

function run_python() {
    if [[ "$1" =~ 'test' ]] ; then
        pytest "$@"
    else
        python "$@"
    fi
}

function run_notebook() {
    jupyter notebook "$@"
}

function run_haskell() { 
    local name="$(get_base_name $1)"
    ghc -dynamic "$1" 
    shift
    "./$name" "$@"
    
}

function run_html() {
    python -m webbrowser "$1"
}

function run_lex() {
    local name="$(get_base_name $1)"
    flex -o "$name.c" "$1"
    gcc -g -Wall -Wpedantic -o "$name" "$name.c"
    shift
    "./$name" "$@"
}


[[ "$#@" -eq '0' ]] && exit


PRG="$1"
shift

[[ -e "$PRG" ]] || die "$PRG does not exist"

typeset -A RUNNERS=(
    'ipynb' 'run_notebook'
    'php' 'php'
    'py' 'run_python'
    'rb' 'ruby'
    'pl' 'perl'
    'zsh' 'zsh'
    'bash' 'bash'
    'sh' 'sh'
    'c' 'run_c'
    'cpp' 'run_cpp'
    'go' 'run_go'
    'rs' 'run_rust'
    'lua' 'lua'
    'tex' 'run_latex'
    'js' 'node'
    'html' 'run_html'
    'hs' 'run_haskell'
    'ex' 'elixir'
    'lex' 'run_lex'
)
EXT=$(echo "$PRG" | perl -pe 's|.+\.(\w+)|$1|')

RUNNER="${RUNNERS[$EXT]}"

if [[ "$RUNNER" ]] ; then
    load_settings
    "$RUNNER" "$PRG" "$@"
else
    die "unknown extension: $EXT"
fi

