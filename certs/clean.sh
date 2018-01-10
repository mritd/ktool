#!/bin/bash

rm -f k8s/{*.pem,*.csr,*.yaml,*.kubeconfig,token.csv}
rm -f etcd/{*.pem,*.csr}

rm -rf ../k8s/conf/{*.kubeconfig,*.yaml,token.csv,ssl}
rm -rf ../etcd/conf/ssl
