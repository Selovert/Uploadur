#!/bin/bash
set -e
set -o pipefail
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 update_archive private_key"
  exit 1
fi
openssl=/usr/bin/openssl
$openssl dgst -sha1 -binary < "webhosting assets/Binaries/Uploadur-$1.zip" | $openssl dgst -dss1 -sign "/Users/tassilo/Google Drive/Dev/Uploadur/dsa_priv.pem" | $openssl enc -base64
