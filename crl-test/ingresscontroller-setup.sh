#!/bin/bash

# ingresscontroller-setup.sh
# Creates the clientCA configmap and patches the default ingresscontroller to enable mTLS. Can be re-invoked to update
# the clientCA configmap
#
# Relies on KUBECONFIG environment variable to point to the cluster to use
set -e
echo "Creating CA configmap..."
oc -n openshift-config delete configmap crl-test-cm --ignore-not-found=true
oc -n openshift-config create configmap crl-test-cm --from-file=ca-bundle.pem=artifacts/ca-bundle.pem
echo "Patching ingresscontroller/default"
oc patch --type=merge -n openshift-ingress-operator ingresscontroller/default --patch '{"spec": {"clientTLS": {"clientCA": {"name": "crl-test-cm"}, "clientCertificatePolicy": "Required"}}}'
