#!/bin/bash

rm -f kubernetes/*.pem kubernetes/*.csr kubernetes/*.yaml kubernetes/*.kubeconfig kubernetes/token.csv
rm -f etcd/*.pem etcd/*.csr

rm -rf ../k8s/conf/*.kubeconfig ../k8s/conf/*.yaml ../k8s/conf/*.csv ../k8s/conf/ssl
rm -rf ../etcd/conf/ssl
