A minimal config to enable mTLS on OpenShift. The scripts in this directory create a self-signed CA key/cert pair, as
well as a key/cert pair that's signed by that CA for use by a client. It will also deploy the CA certificate into a
configmap and enable mTLS on the default ingress controller using that CA as the client CA.

To create the appropriate key/cert pairs and enable mTLS, run `enable-mtls.sh`.
