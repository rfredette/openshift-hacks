#!/bin/bash

# fix-ca-bundle.sh
# Updates ca-bundle.pem to include a leaf certificate. This makes sure all CRL distribution points are specified in the
# CA bundle, making HAProxy accept connections from any of the unrevoked certificates

set -e
echo "Updating ca bundle..."
cat artifacts/signed-by-intermediate.crt artifacts/intermediate-ca.crt artifacts/root-ca.crt > artifacts/ca-bundle.pem
