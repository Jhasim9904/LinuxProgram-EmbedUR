#!/bin/bash

ERROR_LOG="errors.log"

show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -k <keyword>     Keyword to search
  -f <file>        File to search directly
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}

log_error() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG"
}

recursive_search() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -f "$item" ]; then
            if grep -q "$keyword" "$item"; then
                echo "Keyword found in file: $item"
            fi
        elif [ -d "$item" ]; then
            recursive_search "$item" "$keyword"
        fi
    done
}

DIR=""
KEYWORD=""
FILE=""

if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

while getopts ":d:k:f:" opt; do
    case $opt in
        d) DIR="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        \?)
            log_error "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            log_error "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

echo "Script Name : $0"
echo "Arguments Count : $#"
echo "Arguments Passed : $@"

if [[ -z "$KEYWORD" ]]; then
    log_error "Keyword cannot be empty."
    exit 1
fi

if [[ ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then
    log_error "Keyword contains invalid characters."
    exit 1
fi

if [ -n "$FILE" ]; then
    if [ ! -f "$FILE" ]; then
        log_error "File '$FILE' does not exist."
        exit 1
    fi

    echo "Searching keyword '$KEYWORD' in file '$FILE'..."
    grep "$KEYWORD" <<< "$(cat "$FILE")"
    echo "Exit status: $?"
    exit 0
fi


if [ -n "$DIR" ]; then
    if [ ! -d "$DIR" ]; then
        log_error "Directory '$DIR' does not exist."
        exit 1
    fi

    echo "Recursively searching '$DIR' for keyword '$KEYWORD'..."
    recursive_search "$DIR" "$KEYWORD"
    echo "Exit status: $?"
    exit 0
fi

log_error "Invalid usage. Use --help for instructions."
exit 1
