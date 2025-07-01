#!/bin/bash

# Define input and output files
TRAIN_QUERIES="msmarco-doctrain-queries.tsv"
DEV_QUERIES="msmarco-docdev-queries.tsv"
OUTPUT="combined-queries.tsv"

# Check if input files exist
if [[ ! -f "$TRAIN_QUERIES" ]]; then
    echo "Error: $TRAIN_QUERIES not found"
    exit 1
fi
if [[ ! -f "$DEV_QUERIES" ]]; then
    echo "Error: $DEV_QUERIES not found"
    exit 1
fi

# Combine files using cat and write to output
cat "$TRAIN_QUERIES" "$DEV_QUERIES" > "$OUTPUT"

# Verify row count (optional)
TRAIN_COUNT=$(wc -l < "$TRAIN_QUERIES")
DEV_COUNT=$(wc -l < "$DEV_QUERIES")
COMBINED_COUNT=$(wc -l < "$OUTPUT")
EXPECTED_COUNT=$((TRAIN_COUNT + DEV_COUNT))

echo "Training queries: $TRAIN_COUNT"
echo "Dev queries: $DEV_COUNT"
echo "Combined queries: $COMBINED_COUNT"
if [[ "$COMBINED_COUNT" -eq "$EXPECTED_COUNT" ]]; then
    echo "Success: Combined file created with expected row count"
else
    echo "Warning: Combined row count ($COMBINED_COUNT) does not match expected ($EXPECTED_COUNT)"
fi