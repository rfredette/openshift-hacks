#!/bin/bash

# cert-gen.sh
# generates a CA certificate, and a leaf certificate signed by that CA.

set -e
mkdir -p artifacts
echo "Generating root CA..."
openssl req -new -key artifacts/root-ca.key -out artifacts/root-ca.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Test Root CA"
# Root CA has no higher authority, so it's CSR is self-signed
openssl x509 -req -in artifacts/root-ca.csr -out artifacts/root-ca.crt -days 1 -signkey artifacts/root-ca.key -extfile configs/root-ca.cnf
echo "Generating client certificate signed by root..."
openssl req -new -key artifacts/signed-by-root.key -out artifacts/signed-by-root.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Test Client"
openssl x509 -req -days 1 -in artifacts/signed-by-root.csr -CA artifacts/root-ca.crt -CAcreateserial -CAkey artifacts/root-ca.key -out artifacts/signed-by-root.crt --extfile configs/root-client.cnf
