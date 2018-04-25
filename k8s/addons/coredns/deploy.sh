#!/bin/bash

# Deploys CoreDNS to a cluster currently running Kube-DNS.

SERVICE_CIDR=${1:-10.254.0.0/16}
POD_CIDR=${2:-10.20.0.0/16}
CLUSTER_DNS_IP=${3:-10.254.0.2}
CLUSTER_DOMAIN=${4:-cluster.local}
YAML_TEMPLATE=${5:-`pwd`/coredns.yaml.sed}

sed -e s/CLUSTER_DNS_IP/$CLUSTER_DNS_IP/g -e s/CLUSTER_DOMAIN/$CLUSTER_DOMAIN/g -e s?SERVICE_CIDR?$SERVICE_CIDR?g -e s?POD_CIDR?$POD_CIDR?g $YAML_TEMPLATE > coredns.yaml
