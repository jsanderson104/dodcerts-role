#!/bin/bash


if [ $# -ne 1 ]; then
	echo "Need a path to nssdb as an argument to this script"
	exit 1
fi


if [ "$(whoami)" != "root" ]; then
	echo "Must be root user. Exiting."
	exit 2
fi

if [ ! -z $1 ]; then
	echo "Path doesn\'t exist.. Exiting."
	exit 3
fi



# Path to your NSS database directory (without sql: prefix if using certutil standard)
# Example: sql:/etc/pki/nssdb or /home/user/.pki/nssdb
NSS_DB=$1

# Loop through all pem files in the current directory
for pem in *.pem; do
  # Skip if no pem files exist
  [ -e "$pem" ] || continue

  # Get the filename without the .pem extension to use as alias
  alias="${pem%.pem}"

  echo "Importing $pem as alias '$alias'..."

  # Run certutil to add the certificate
  certutil -d "$NSS_DB" -A -n "$alias" -t "CT,C,C" -i "$pem"
done

echo "Done!"

