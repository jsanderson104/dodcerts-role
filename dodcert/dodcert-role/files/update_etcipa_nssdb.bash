#!/bin/bash
TARGET_DB=$1
cert=$2

filename=$(basename -- "$cert")
alias="${filename%.*}"
certutil  -f $TARGET_DB/pwdfile.txt -d "$TARGET_DB" -A -n "$alias" -t "CT,C,C" -i "$cert"

