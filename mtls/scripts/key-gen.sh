#!/bin/bash

# key-gen.sh
# Generate keys for use with various testing certificates generated elsewhere in this repo. The keys don't technically
# expire, so they shouldn't need to be regenerated if already present

set -e
mkdir -p artifacts
echo "Generating root CA key..."
openssl genrsa -out artifacts/root-ca.key 2048
echo "Generating key for root-signed client cert..."
openssl genrsa -out artifacts/signed-by-root.key 2048
