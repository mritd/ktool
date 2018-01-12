#!/bin/bash

set -e

K8S_MASTER_IP=$1
ETCD_ENDPOINTS=$2
CALICO_VERSION="3.0.1"

if [ "" == "${K8S_MASTER_IP}" ]; then
   echo -e "\033[33mWARNING: K8S_MASTER_IP is blank,use default value: 172.16.0.81\033[0m"
   K8S_MASTER_IP="172.16.0.81"
fi

if [ "" == "${ETCD_ENDPOINTS}" ]; then
    echo -e "\033[33mWARNING: K8S_MASTER_IP is blank,use default value: https://172.16.0.81:2379,https://172.16.0.82:2379,https://172.16.0.83:2379\033[0m"
    ETCD_ENDPOINTS="https://172.16.0.81:2379,https://172.16.0.82:2379,https://172.16.0.83:2379"
fi

HOSTNAME=`cat /etc/hostname`
ETCD_CERT=`cat /etc/etcd/ssl/etcd.pem | base64 | tr -d '\n'`
ETCD_KEY=`cat /etc/etcd/ssl/etcd-key.pem | base64 | tr -d '\n'`
ETCD_CA=`cat /etc/etcd/ssl/etcd-root-ca.pem | base64 | tr -d '\n'`


cp calico.example.yaml calico.yaml

sed -i "s@.*etcd_endpoints:.*@\ \ etcd_endpoints:\ \"${ETCD_ENDPOINTS}\"@gi" calico.yaml

sed -i "s@.*etcd-cert:.*@\ \ etcd-cert:\ ${ETCD_CERT}@gi" calico.yaml
sed -i "s@.*etcd-key:.*@\ \ etcd-key:\ ${ETCD_KEY}@gi" calico.yaml
sed -i "s@.*etcd-ca:.*@\ \ etcd-ca:\ ${ETCD_CA}@gi" calico.yaml

sed -i 's@.*etcd_ca:.*@\ \ etcd_ca:\ "/calico-secrets/etcd-ca"@gi' calico.yaml
sed -i 's@.*etcd_cert:.*@\ \ etcd_cert:\ "/calico-secrets/etcd-cert"@gi' calico.yaml
sed -i 's@.*etcd_key:.*@\ \ etcd_key:\ "/calico-secrets/etcd-key"@gi' calico.yaml

# 注释掉 calico-node 部分(由 Systemd 接管)
sed -i '119,210s@.*@#&@gi' calico.yaml

cat > /lib/systemd/system/calico-node.service <<EOF
[Unit]
Description=calico node
After=docker.service
Requires=docker.service

[Service]
User=root
Environment=ETCD_ENDPOINTS=${ETCD_ENDPOINTS}
PermissionsStartOnly=true
ExecStart=/usr/bin/docker run   --net=host --privileged --name=calico-node \\
                                -e ETCD_ENDPOINTS=\${ETCD_ENDPOINTS} \\
                                -e ETCD_CA_CERT_FILE=/etc/etcd/ssl/etcd-root-ca.pem \\
                                -e ETCD_CERT_FILE=/etc/etcd/ssl/etcd.pem \\
                                -e ETCD_KEY_FILE=/etc/etcd/ssl/etcd-key.pem \\
                                -e NODENAME=${HOSTNAME} \\
                                -e IP= \\
                                -e IP_AUTODETECTION_METHOD=can-reach=${K8S_MASTER_IP} \\
                                -e AS=64512 \\
                                -e CLUSTER_TYPE=k8s,bgp \\
                                -e CALICO_IPV4POOL_CIDR=10.20.0.0/16 \\
                                -e CALICO_IPV4POOL_IPIP=always \\
                                -e CALICO_LIBNETWORK_ENABLED=true \\
                                -e CALICO_NETWORKING_BACKEND=bird \\
                                -e CALICO_DISABLE_FILE_LOGGING=true \\
                                -e FELIX_IPV6SUPPORT=false \\
                                -e FELIX_DEFAULTENDPOINTTOHOSTACTION=ACCEPT \\
                                -e FELIX_LOGSEVERITYSCREEN=info \\
                                -e FELIX_IPINIPMTU=1440 \\
                                -e FELIX_HEALTHENABLED=true \\
                                -e CALICO_K8S_NODE_REF=${HOSTNAME} \\
                                -v /etc/etcd/ssl/etcd-root-ca.pem:/etc/etcd/ssl/etcd-root-ca.pem \\
                                -v /etc/etcd/ssl/etcd.pem:/etc/etcd/ssl/etcd.pem \\
                                -v /etc/etcd/ssl/etcd-key.pem:/etc/etcd/ssl/etcd-key.pem \\
                                -v /lib/modules:/lib/modules \\
                                -v /var/run/calico:/var/run/calico \\
                                quay.io/calico/node:v3.0.1
ExecStop=/usr/bin/docker rm -f calico-node
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# Download calico image
if [ ! -f "calico_v${CALICO_VERSION}.tar.gz" ]; then
    wget https://mritdftp.b0.upaiyun.com/files/calico/calico_v${CALICO_VERSION}.tar.gz
fi

# Load calico image
tar -zxvf calico_v${CALICO_VERSION}.tar.gz > images
for imageName in `cat images`; do
    docker load < $imageName
done
rm -f *.tar images

echo -e "\033[32m\nGenerate the configuration file done! Next:\n\033[0m"
echo -e "\033[32mUse \"kubectl create -f rbac.yaml\" to create RBAC resources.\033[0m"
echo -e "\033[32mUse \"kubectl create -f calico.yaml\" to create calico-kube-controllers.\033[0m"
echo -e "\033[32mUse \"systemctl start calico-node\" to start calico-node service.\033[0m"
