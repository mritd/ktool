#!/bin/bash

set -e

# 允许 kubelet tls bootstrap 创建 csr 请求
kubectl create clusterrolebinding create-csrs-for-bootstrapping \
    --clusterrole=system:node-bootstrapper \
    --group=system:bootstrappers

# 自动批准 system:bootstrappers 组用户 TLS bootstrapping 首次申请证书的 CSR 请求
kubectl create clusterrolebinding auto-approve-csrs-for-group \
    --clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient \
    --group=system:bootstrappers

# 自动批准 system:nodes 组用户更新 kubelet 自身与 apiserver 通讯证书的 CSR 请求
kubectl create clusterrolebinding auto-approve-renewals-for-nodes \
    --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient \
    --group=system:nodes

# 在 kubelet server 开启 api 认证的情况下，apiserver 反向访问 kubelet 10250 需要此授权(eg: kubectl logs)
kubectl create clusterrolebinding system:kubelet-api-admin \
    --clusterrole=system:kubelet-api-admin \
    --user=system:kubelet-api-admin
