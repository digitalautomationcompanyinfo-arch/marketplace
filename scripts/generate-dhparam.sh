#!/bin/sh
set -e
# Script to generate a 2048-bit DH parameters file for Nginx
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/nginx/ssl"
OUT_FILE="$OUT_DIR/dhparam.pem"

if [ -f "$OUT_FILE" ]; then
  echo "dhparam already exists at $OUT_FILE"
  exit 0
fi

echo "Generating 2048-bit DH parameters (this may take a while)..."
mkdir -p "$OUT_DIR"
openssl dhparam -out "$OUT_FILE" 2048
echo "dhparam generated at $OUT_FILE"
