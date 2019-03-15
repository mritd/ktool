#!/bin/bash

rm -f *.pem *.csr *.yaml *.kubeconfig token.csv
rm -rf ../conf/{*.kubeconfig,*.yaml,token.csv,ssl}
