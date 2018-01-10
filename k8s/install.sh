#!/bin/bash

set -e

KUBE_DEFAULT_VERSION="1.8.6"

if [ "$1" != "" ]; then
  KUBE_VERSION=$1
else
  echo -e "\033[33mWARNING: KUBE_VERSION is blank,use default version: ${KUBE_DEFAULT_VERSION}\033[0m"
  KUBE_VERSION=${KUBE_DEFAULT_VERSION}
fi

function download_k8s(){
    if [ ! -f "hyperkube_${KUBE_VERSION}" ]; then
        wget https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/hyperkube -O hyperkube_${KUBE_VERSION}
        chmod +x hyperkube_${KUBE_VERSION}
    fi
}


function preinstall(){
    getent group kube >/dev/null || groupadd -r kube
    getent passwd kube >/dev/null || useradd -r -g kube -d / -s /sbin/nologin -c "Kubernetes user" kube
}

function install_k8s(){
    echo -e "\033[32mINFO: Copy hyperkube...\033[0m"
    cp hyperkube_${KUBE_VERSION} /usr/local/bin/hyperkube

    echo -e "\033[32mINFO: Create symbolic link...\033[0m"
    ln -sf /usr/local/bin/hyperkube /usr/local/bin/kubectl

    echo -e "\033[32mINFO: Copy kubernetes config...\033[0m"
    cp -r conf /etc/kubernetes
    if [ -d "/etc/kubernetes/ssl" ]; then
        chown -R kube:kube /etc/kubernetes/ssl
    fi

    echo -e "\033[32mINFO: Copy kubernetes systemd config...\033[0m"
    cp systemd/*.service /lib/systemd/system
    systemctl daemon-reload
}

function postinstall(){
    if [ ! -d "/var/log/kube-audit" ]; then
        mkdir /var/log/kube-audit
    fi
    
    if [ ! -d "/var/lib/kubelet" ]; then
        mkdir /var/lib/kubelet
    fi
    chown -R kube:kube /var/log/kube-audit /var/lib/kubelet
}


download_k8s
preinstall
install_k8s
postinstall
