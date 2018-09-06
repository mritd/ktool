#!/bin/bash

set -e

K8S_MASTER_IP=$1
ETCD_ENDPOINTS=$2
CALICO_VERSION="3.1.0"

if [ "" == "${K8S_MASTER_IP}" ]; then
   echo -e "\033[33mWARNING: K8S_MASTER_IP is blank,use default value: 192.168.1.61\033[0m"
   K8S_MASTER_IP="192.168.1.61"
fi

if [ "" == "${ETCD_ENDPOINTS}" ]; then
    echo -e "\033[33mWARNING: ETCD_ENDPOINTS is blank,use default value: https://192.168.1.61:2379,https://192.168.1.62:2379,https://192.168.1.63:2379\033[0m"
    ETCD_ENDPOINTS="https://192.168.1.61:2379,https://192.168.1.62:2379,https://192.168.1.63:2379"
fi

HOSTNAME=`cat /etc/hostname`
ETCD_CERT=`cat conf/etcd.pem | base64 | tr -d '\n'`
ETCD_KEY=`cat conf/etcd-key.pem | base64 | tr -d '\n'`
ETCD_CA=`cat conf/etcd-root-ca.pem | base64 | tr -d '\n'`


cp calico.example.yaml calico.yaml

sed -i "s@.*etcd_endpoints:.*@\ \ etcd_endpoints:\ \"${ETCD_ENDPOINTS}\"@gi" calico.yaml

sed -i "s@.*etcd-cert:.*@\ \ etcd-cert:\ ${ETCD_CERT}@gi" calico.yaml
sed -i "s@.*etcd-key:.*@\ \ etcd-key:\ ${ETCD_KEY}@gi" calico.yaml
sed -i "s@.*etcd-ca:.*@\ \ etcd-ca:\ ${ETCD_CA}@gi" calico.yaml

sed -i 's@.*etcd_ca:.*@\ \ etcd_ca:\ "/calico-secrets/etcd-ca"@gi' calico.yaml
sed -i 's@.*etcd_cert:.*@\ \ etcd_cert:\ "/calico-secrets/etcd-cert"@gi' calico.yaml
sed -i 's@.*etcd_key:.*@\ \ etcd_key:\ "/calico-secrets/etcd-key"@gi' calico.yaml

sed -i "s@K8S_MASTER_IP@${K8S_MASTER_IP}@gi" calico.yaml

wget https://github.com/projectcalico/calicoctl/releases/download/v3.2.1/calicoctl-linux-amd64 -O /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl

sed -i "s@.*etcdEndpoints:.*@\ \ etcdEndpoints:\ ${ETCD_ENDPOINTS}@gi" conf/calicoctl.cfg

rm -rf /etc/calico && cp -r conf /etc/calico

echo -e "\033[32m\nGenerate the configuration file done! Next:\n\033[0m"
echo -e "\033[32mUse \"kubectl create -f rbac.yaml\" to create RBAC resources.\033[0m"
echo -e "\033[32mUse \"kubectl create -f calico.yaml\" to create calico-kube-controllers.\033[0m"
echo -e "\033[32m\nFinally, do not forget to add an \"--network-plugin=cni\" option to kubelet.\033[0m"
