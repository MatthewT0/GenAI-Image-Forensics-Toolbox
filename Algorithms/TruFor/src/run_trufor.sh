#!/usr/bin/env bash
# =========================================
#  TruFor Local Execution Script (Linux/macOS)
# =========================================

# Set the input and output directories (handling ../images)
INPUT_DIR="$(realpath "$(dirname "$0")/../images")"
OUTPUT_DIR="$(realpath "$(dirname "$0")/../output")"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Run the Python script python 3.13.1
py trufor_test.py -gpu 0 -in "$INPUT_DIR" -out "$OUTPUT_DIR"

echo "=============================="
echo "TruFor execution completed!"
echo "Output saved in $OUTPUT_DIR"
echo "=============================="
