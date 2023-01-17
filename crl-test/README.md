# [bz-2118284](https://bugzilla.redhat.com/show_bug.cgi?id=2118284) mtls CRL not working when using an intermediate CA
## Setup
- Root CA has no CRL distribution point (CDP)
- Intermediate CA is signed by root, and has the CDP for the root CA CRL
- Client certificate is signed by intermediate, and has the CDP for the intermediate CA
- Ingress controller is configured with mTLS, and has both the Root and Intermediate CA certificates
## Test
- Using a client certificate signed by the intermediate CA (which includes the intermediate CA CDP), curl a backend
	- Should succeed, but currently fails because intermediate CA CDP is not downloaded
- Using a client certificate signed by the root CA (which includes the root CA CDP), curl a backend
	- should succeed, does succeed

