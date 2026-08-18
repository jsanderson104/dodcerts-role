#!/bin/bash

file=$1

  [ -e "$file" ] || continue
  subject=$(openssl x509 -noout -subject -in "$file")
  cn=$(echo "$subject" | sed -n 's/.*CN[[:space:]]*=[[:space:]]*\([^/]*\).*/\1/p')
  if [ -n "$cn" ]; then
    safe_name=$(echo "$cn" | tr ' ' '_')
    mv "$file" "{{cert_workingdir_intermediates}}/${safe_name}.crt"
    echo "Renamed $file to ${safe_name}.crt"
  else
    echo "Could not find CN in $file"
  fi

