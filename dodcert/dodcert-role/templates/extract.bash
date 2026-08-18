#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if input file argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-p7b-file>"
    exit 1
fi

INPUT_FILE="$1"
FILENAME=$(basename -- "$INPUT_FILE")
BASE_NAME="${FILENAME%.*}"
COMBINED_PEM="{{cert_workingdir_combined}}/${BASE_NAME}_combined.pem"

# 1. Detect encoding (PEM vs DER) and extract the full chain into a temporary file
echo "Analyzing and extracting certificates from $INPUT_FILE..."

if grep -q "BEGIN PKCS7" "$INPUT_FILE" 2>/dev/null; then
    # File is PEM (ASCII text encoded)
    openssl pkcs7 -print_certs -inform PEM -in "$INPUT_FILE" -out "$COMBINED_PEM"
else
    # File is DER (Binary encoded)
    openssl pkcs7 -print_certs -inform DER -in "$INPUT_FILE" -out "$COMBINED_PEM"
fi

echo "Saved combined certificate bundle to: $COMBINED_PEM"

# 2. Split the bundle into individual certificate files
echo "Splitting bundle into individual files..."

# Count variables for renaming
count=1

# Read the bundle file line by line to parse individual certificates cleanly
while IFS= read -r line || [ -n "$line" ]; do
    # Identify the start of a certificate block
    if [[ "$line" =~ -----BEGIN[[:space:]]CERTIFICATE----- ]]; then
        OUT_FILE="{{cert_workingdir_base}}/${BASE_NAME}_cert_${count}.crt"
        #OUT_FILE="${BASE_NAME}_cert_${count}.crt"
        echo "Extracting $OUT_FILE..."
        echo "$line" > "$OUT_FILE"
        inside_cert=true
    # Identify inside block content
    elif [ "$inside_cert" = true ]; then
        echo "$line" >> "$OUT_FILE"
        # Identify the end of the block
        if [[ "$line" =~ -----END[[:space:]]CERTIFICATE----- ]]; then
            inside_cert=false
            ((count++))
        fi
    fi
done < "$COMBINED_PEM"

echo "Extraction complete! Total certificates extracted: $((count-1))"

