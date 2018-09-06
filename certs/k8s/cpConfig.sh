#!/bin/bash

rm -rf ../../k8s/conf/ssl
rm -f ../../k8s/conf/*.csv
rm -f ../../k8s/conf/*.yaml
rm -f ../../k8s/conf/*.kubeconfig

mkdir ../../k8s/conf/ssl
cp *.pem ../../k8s/conf/ssl
cp *.yaml ../../k8s/conf
cp *.kubeconfig ../../k8s/conf
