#!/bin/bash

# revoke.sh
# Revokes the revoked-by-root and revoked-by-intermediate certificates that were generated in cert-gen.sh.
# crl-host-setup.sh will need to be executed manually to update the crl host pod.
#
# openssl doesn't allow CRLs to be valid for less than 1 hour, so in order to make them expire sooner, call this script
# using faketime. For example, to make the CRLs expire in 15 minutes, run this:
# faketime '45 minutes ago' revoke.sh
set -e
echo "Revoking revoked-by-root.crt..."
openssl ca -revoke artifacts/revoked-by-root.crt -config configs/root-ca.cnf
openssl ca -gencrl -crlhours 1 -out artifacts/root.crl -config configs/root-ca.cnf
echo "Revoking revoked-by-intermediate.crt..."
openssl ca -revoke artifacts/revoked-by-intermediate.crt -config configs/intermediate-ca.cnf
openssl ca -gencrl -crlhours 1 -out artifacts/intermediate.crl -config configs/intermediate-ca.cnf
