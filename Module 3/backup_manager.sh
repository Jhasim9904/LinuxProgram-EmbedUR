#!/bin/bash

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

export BACKUP_COUNT=0

FILES=("$SOURCE_DIR"/*"$EXTENSION")

if [ ! -e "${FILES[0]}" ]; then
    echo "No files with extension $EXTENSION found in $SOURCE_DIR"
    exit 1
fi

TOTAL_SIZE=0
echo "Files selected for backup:"
for file in "${FILES[@]}"; do
    size=$(stat -c %s "$file")
    echo "$(basename "$file") - $size bytes"
    TOTAL_SIZE=$((TOTAL_SIZE + size))
done

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || {
        echo "Error: Failed to create backup directory."
        exit 1
    }
fi

for file in "${FILES[@]}"; do
    dest="$BACKUP_DIR/$(basename "$file")"

    if [ -e "$dest" ]; then
        if [ "$file" -nt "$dest" ]; then
            cp "$file" "$dest"
            ((BACKUP_COUNT++))
        fi
    else
        cp "$file" "$dest"
        ((BACKUP_COUNT++))
    fi
done

REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
    echo "Backup Report"
    echo "----------------------------"
    echo "Source Directory : $SOURCE_DIR"
    echo "Backup Directory : $BACKUP_DIR"
    echo "File Extension   : $EXTENSION"
    echo "Total Files Backed Up : $BACKUP_COUNT"
    echo "Total Size Backed Up  : $TOTAL_SIZE bytes"
    echo "Backup Time      : $(date)"
} > "$REPORT_FILE"

echo "Backup completed successfully."
echo "Report saved at: $REPORT_FILE"
