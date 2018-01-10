#!/bin/bash

KUBE_VERSION="$1"

if [ "" == "${KUBE_VERSION}" ]; then
   echo -e "\033[33mWARNING: KUBE_VERSION is blank,use default version: 1.8\033[0m"
   KUBE_VERSION="1.8"
fi

kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap

kubectl create -f tls-bootstrapping-clusterrole-${KUBE_VERSION}.yaml

# 自动批准 system:bootstrappers 组用户 TLS bootstrapping 首次申请证书的 CSR 请求
kubectl create clusterrolebinding node-client-auto-approve-csr \
	--clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient \
	--group=system:bootstrappers

# 自动批准 system:nodes 组用户更新 kubelet 自身与 apiserver 通讯证书的 CSR 请求
kubectl create clusterrolebinding node-client-auto-renew-crt \
	--clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient \
	--group=system:nodes

# 自动批准 system:nodes 组用户更新 kubelet 10250 api 端口证书的 CSR 请求
kubectl create clusterrolebinding node-server-auto-renew-crt \
	--clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeserver \
	--group=system:nodes
