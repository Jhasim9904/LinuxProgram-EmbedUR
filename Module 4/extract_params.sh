#!/bin/bash

if [ "$#" -ne 1 ]; then
   echo "Usage: $0 <input_file>"
   exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file does not exist."
    exit 1
fi

> "$OUTPUT_FILE"

grep -E '"frame.time"|\"wlan.fc.type\"|\"wlan.fc.subtype\"' "$INPUT_FILE" |
while read -r line
do
    echo "$line" >> "$OUTPUT_FILE"
done

echo "Extraction completed successfully."
echo "Output saved in: $(pwd)/output.txt"
