#!/bin/bash

# crl-host-setup.sh
# Creates the configmaps and host pod which will host CRLs generated by the scripts in this repo. This script can be
# re-invoked when artifacts/root.crl or artifacts/intermediate.crl are updated in order to serve the updated versions.
#
# Relies on KUBECONFIG environment variable to point to the cluster to use
echo "Creating namespace crl-test..."
oc create namespace crl-test
echo "Creating root CRL configmap..."
oc -n crl-test delete configmap crl-root --ignore-not-found=true
oc -n crl-test create configmap crl-root --from-file=artifacts/root.crl
echo "Creating intermediate CRL configmap..."
oc -n crl-test delete configmap crl-intermediate --ignore-not-found=true
oc -n crl-test create configmap crl-intermediate --from-file=artifacts/intermediate.crl
echo "Creating CRL host container..."
oc apply -f crl-host.yaml
