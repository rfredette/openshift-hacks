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
echo "Generating intermediate CA..."
openssl req -new -key artifacts/intermediate-ca.key -out artifacts/intermediate-ca.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Test Intermediate CA"
openssl x509 -req -in artifacts/intermediate-ca.csr -out artifacts/intermediate-ca.crt -days 3650 -CA artifacts/root-ca.crt -CAcreateserial -CAkey artifacts/root-ca.key -extfile configs/intermediate-ca.cnf
echo "Generating CA certificate bundle..."
# A .pem file is just several certs concatinated. RFC 4346 (https://www.rfc-editor.org/rfc/rfc4346#section-7.4.2,
# describing `certificate_list`) essentially states that the cert farthest from the root should be first, and it should
# be followed by each cert closer to the root that's included, in order
cat artifacts/intermediate-ca.crt artifacts/root-ca.crt > artifacts/ca-bundle.pem
echo "Generating client certificate signed by root..."
openssl req -new -key artifacts/signed-by-root.key -out artifacts/signed-by-root.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Test Client"
openssl x509 -req -days 1 -in artifacts/signed-by-root.csr -CA artifacts/root-ca.crt -CAcreateserial -CAkey artifacts/root-ca.key -out artifacts/signed-by-root.crt --extfile configs/root-client.cnf
cat artifacts/signed-by-root.crt artifacts/root-ca.crt > artifacts/signed-by-root.pem
echo "Generating client certificate signed by intermediate..."
openssl req -new -key artifacts/signed-by-intermediate.key -out artifacts/signed-by-intermediate.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Another Test Client"
openssl x509 -req -days 1 -in artifacts/signed-by-intermediate.csr -CA artifacts/intermediate-ca.crt -CAcreateserial -CAkey artifacts/intermediate-ca.key -out artifacts/signed-by-intermediate.crt -extfile configs/client-ext.cnf
cat artifacts/signed-by-intermediate.crt artifacts/intermediate-ca.crt artifacts/root-ca.crt > artifacts/signed-by-intermediate.pem
echo "Generating certificate for root to revoke..."
openssl req -new -key artifacts/revoked-by-root.key -out artifacts/revoked-by-root.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Revoked by Root Test"
openssl x509 -req -days 1 -in artifacts/revoked-by-root.csr -CA artifacts/root-ca.crt -CAcreateserial -CAkey artifacts/root-ca.key -out artifacts/revoked-by-root.crt --extfile configs/root-client.cnf
cat artifacts/revoked-by-root.crt artifacts/root-ca.crt > artifacts/revoked-by-root.pem
echo "Generating certificate for intermediate to revoke..."
openssl req -new -key artifacts/revoked-by-intermediate.key -out artifacts/revoked-by-intermediate.csr -subj "/C=US/ST=NC/L=Raleigh/O=OS4/OU=Eng/CN=Revoked by Intermediate Test"
openssl x509 -req -days 1 -in artifacts/revoked-by-intermediate.csr -CA artifacts/intermediate-ca.crt -CAcreateserial -CAkey artifacts/intermediate-ca.key -out artifacts/revoked-by-intermediate.crt -extfile configs/client-ext.cnf
cat artifacts/revoked-by-intermediate.crt artifacts/intermediate-ca.crt artifacts/root-ca.crt > artifacts/revoked-by-intermediate.pem
echo "Generating root CRL..."
# Blank out index.txt to reset the list of revoked certs
cat /dev/null > artifacts/root-crl-index.txt
faketime '5 minutes ago' openssl ca -gencrl -crlhours 1 -out artifacts/root.crl -config configs/root-ca.cnf
echo "Generating intermediate CRL..."
# Blank out index.txt to reset the list of revoked certs
cat /dev/null > artifacts/intermediate-crl-index.txt
openssl ca -gencrl -crlhours 1 -out artifacts/intermediate.crl -config configs/intermediate-ca.cnf
