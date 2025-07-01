#!/bin/bash

# Script to add an id column to a TSV file
# Usage: ./add_id_to_tsv.sh -i input.tsv -o output.tsv

# Function to display usage
usage() {
    echo "Usage: $0 -i <input_tsv> -o <output_tsv>"
    echo "  -i: Input TSV file"
    echo "  -o: Output TSV file with id column"
    exit 1
}

# Parse command-line arguments
while getopts "i:o:" opt; do
    case $opt in
        i) INPUT="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
    echo "Error: Both input (-i) and output (-o) arguments are required"
    usage
fi

# Check if input file exists
if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file '$INPUT' not found"
    exit 1
fi

# Add id column (starting from 1) using awk
awk 'BEGIN {FS=OFS="\t"} {print NR, $0}' "$INPUT" > "$OUTPUT"

# Verify row count
INPUT_COUNT=$(wc -l < "$INPUT")
OUTPUT_COUNT=$(wc -l < "$OUTPUT")

echo "Input file: $INPUT"
echo "Output file: $OUTPUT"
echo "Input rows: $INPUT_COUNT"
echo "Output rows: $OUTPUT_COUNT"
if [[ "$INPUT_COUNT" -eq "$OUTPUT_COUNT" ]]; then
    echo "Success: $OUTPUT created with id column"
else
    echo "Error: Row count mismatch (Input: $INPUT_COUNT, Output: $OUTPUT_COUNT)"
    exit 1
fi

# Display first few lines
echo "First 5 lines of $OUTPUT:"
head -n 5 "$OUTPUT"