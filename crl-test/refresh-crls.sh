#!/bin/bash

# refresh-crls.sh
# generate a new version of the CRLs, without modifying the revocation list
#
# openssl doesn't allow CRLs to be valid for less than 1 hour, so in order to make them expire sooner, call this script
# using faketime. For example, to make the CRLs expire in 15 minutes, run this:
# faketime '45 minutes ago' refresh-crls.sh

set -e
mkdir -p artifacts
echo "Generating root CRL..."
# Blank out index.txt to reset the list of revoked certs
openssl ca -gencrl -crlhours 1 -out artifacts/root.crl -config configs/root-ca.cnf
openssl crl -in artifacts/root.crl -inform PEM -out artifacts/root.der.crl -outform der
mv artifacts/root.der.crl artifacts/root.crl
echo "Generating intermediate CRL..."
# Blank out index.txt to reset the list of revoked certs
openssl ca -gencrl -crlhours 1 -out artifacts/intermediate.crl -config configs/intermediate-ca.cnf
openssl crl -in artifacts/intermediate.crl -inform PEM -out artifacts/intermediate.der.crl -outform der
mv artifacts/intermediate.der.crl artifacts/intermediate.crl
