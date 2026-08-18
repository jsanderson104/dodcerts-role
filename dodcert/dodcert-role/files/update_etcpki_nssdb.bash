#!/bin/bash
TARGET_DB=$1
cert=$2

filename=$(basename -- "$cert")
alias="${filename%.*}"
certutil  -d "$TARGET_DB" -A -n "$alias" -t "CT,C,C" -i "$cert"

