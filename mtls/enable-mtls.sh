#!/bin/bash

if ! [[ -f artifacts/root-ca.key && -f artifacts/signed-by-root.key ]] ; then
	scripts/key-gen.sh
fi

scripts/cert-gen.sh
scripts/ingresscontroller-setup.sh
