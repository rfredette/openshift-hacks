# How to use
To generate keys (only needs to be done once):
```bash
$ ./key-gen.sh
```
To generate certificates:
```bash
$ ./cert-gen.sh
```
Both the CA & leaf certificates are only valid for 24 hours.

The keys & certificates will be generated in the `artifacts` directory.
- `root-ca.key` and `root-ca.crt` are the CA key/cert pair
- `signed-by-root.key` and `signed-by-root.crt` are the leaf key/cert pair
