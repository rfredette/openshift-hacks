#!/bin/bash

# cert-gen.sh
# Generates a number of CA and client certificates, and resets CRL indexes for both CAs (meaning no certs will be
# considered revoked). All generated files should be in the artifacts/ directory
#
# openssl doesn't allow CRLs to be valid for less than 1 hour, so in order to make them expire sooner, call this script
# using faketime. For example, to make the CRLs expire in 15 minutes, run this:
# faketime '45 minutes ago' cert-gen.sh

set -e
mkdir -p artifacts
echo "Generating root CA..."
openssl req -new -key artifacts/root-ca.key -out artifacts/root-ca.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Test Root CA"
# Root CA has no higher authority, so it's CSR is self-signed
openssl x509 -req -in artifacts/root-ca.csr -out artifacts/root-ca.crt -days 3650 -signkey artifacts/root-ca.key -extfile configs/root-ca.cnf
echo "Generating CA certificate bundle..."
# A .pem file is just several certs concatinated. RFC 4346 (https://www.rfc-editor.org/rfc/rfc4346#section-7.4.2,
# describing `certificate_list`) essentially states that the cert farthest from the root should be first, and it should
# be followed by each cert closer to the root that's included, in order
cat artifacts/root-ca.crt > artifacts/ca-bundle.pem
echo "Generating client certificate signed by root..."
openssl req -new -key artifacts/signed-by-root.key -out artifacts/signed-by-root.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Test Client"
openssl x509 -req -days 1 -in artifacts/signed-by-root.csr -CA artifacts/root-ca.crt -CAcreateserial -CAkey artifacts/root-ca.key -out artifacts/signed-by-root.crt --extfile configs/root-client.cnf
cat artifacts/signed-by-root.crt artifacts/root-ca.crt > artifacts/signed-by-root.pem
