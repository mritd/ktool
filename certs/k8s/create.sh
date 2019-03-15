#!/bin/bash

set -e

cfssl gencert --initca=true k8s-root-ca-csr.json | cfssljson --bare k8s-root-ca

for targetName in kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet-api-admin admin; do
    cfssl gencert --ca k8s-root-ca.pem --ca-key k8s-root-ca-key.pem --config k8s-gencert.json --profile kubernetes $targetName-csr.json | cfssljson --bare $targetName
done

KUBE_APISERVER="https://127.0.0.1:6443"
BOOTSTRAP_TOKEN_ID=$(head -c 6 /dev/urandom | md5sum | head -c 6)
BOOTSTRAP_TOKEN_SECRET=$(head -c 16 /dev/urandom | md5sum | head -c 16)
BOOTSTRAP_TOKEN="${BOOTSTRAP_TOKEN_ID}.${BOOTSTRAP_TOKEN_SECRET}"

echo "Bootstrap Tokne: ${BOOTSTRAP_TOKEN}"

echo "Create kubelet bootstrapping kubeconfig..."

# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials "system:bootstrap:${BOOTSTRAP_TOKEN_ID}" \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user="system:bootstrap:${BOOTSTRAP_TOKEN_ID}" \
  --kubeconfig=bootstrap.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

echo "Create kube-controller-manager kubeconfig..."

kubectl config set-cluster kubernetes \
  --certificate-authority=k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-controller-manager.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials "system:kube-controller-manager" \
  --client-certificate=kube-controller-manager.pem \
  --client-key=kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig 

echo "Create kube-scheduler kubeconfig..."

kubectl config set-cluster kubernetes \
  --certificate-authority=k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-scheduler.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials "system:kube-scheduler" \
  --client-certificate=kube-scheduler.pem \
  --client-key=kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig 

echo "Create kube-proxy kubeconfig..."

kubectl config set-cluster kubernetes \
  --certificate-authority=k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials "system:kube-proxy" \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig 

cat >> audit-policy.yaml <<EOF
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF

cat >> bootstrap.secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  # Name MUST be of form "bootstrap-token-<token id>"
  name: bootstrap-token-${BOOTSTRAP_TOKEN_ID}
  namespace: kube-system

# Type MUST be 'bootstrap.kubernetes.io/token'
type: bootstrap.kubernetes.io/token
stringData:
  # Human readable description. Optional.
  description: "The default bootstrap token."

  # Token ID and secret. Required.
  token-id: ${BOOTSTRAP_TOKEN_ID}
  token-secret: ${BOOTSTRAP_TOKEN_SECRET}

  # Expiration. Optional.
  expiration: $(date -d'+1 day' -u +"%Y-%m-%dT%H:%M:%SZ")

  # Allowed usages.
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"

  # Extra groups to authenticate the token as. Must start with "system:bootstrappers:"
#  auth-extra-groups: system:bootstrappers:worker,system:bootstrappers:ingress
EOF
