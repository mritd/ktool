#!/bin/bash

set -e

KUBE_DEFAULT_VERSION="1.8.5"
KUBE_CONF_DIR="kubeconfig"
KUBE_CONF_INSTALL_DIR="/etc/kubernetes"
KUBE_SYSTEMD_CONF_DIR="systemd"
KUBE_SYSTEMD_CONF_INSTALL_DIR="/lib/systemd/system"

if [ "$1" != "" ]; then
  KUBE_VERSION=$1
else
  echo -e "\033[33mWARNING: KUBE_VERSION is blank,use default version: ${KUBE_DEFAULT_VERSION}\033[0m"
  KUBE_VERSION=${KUBE_DEFAULT_VERSION}
fi

function download_k8s(){

    if [ ! -f "hyperkube_${KUBE_VERSION}" ]; then
      	wget https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/hyperkube -O hyperkube_${KUBE_VERSION}
        chmod +x hyperkubei_${KUBE_VERSION}
    fi

}

function uninstall_k8s(){

	echo -e "\033[33mWARNING: Delete hyperkube!\033[0m"
	rm -f /usr/local/bin/hyperkube
    rm -f /usr/local/bin/kubectl

	echo -e "\033[33mWARNING: Delete kubernetes config!\033[0m"
    rm -rf ${KUBE_CONF_INSTALL_DIR}
	echo -e "\033[33mDelete: ${KUBE_CONF_INSTALL_DIR}\033[0m"
    
	echo -e "\033[33mWARNING: Delete kubernetes systemd config!\033[0m"
    allServices=(kube-apiserver kube-controller-manager kube-proxy kube-scheduler kubelet)
    for serviceName in ${allServices[@]};do
        if [ -f "${KUBE_SYSTEMD_CONF_INSTALL_DIR}/${serviceName}.service" ]; then
	        systemctl stop ${serviceName}.service
        	rm -f ${KUBE_SYSTEMD_CONF_INSTALL_DIR}/${serviceName}.service
	    	echo -e "\033[33mDelete: ${KUBE_SYSTEMD_CONF_INSTALL_DIR}/${serviceName}.service\033[0m"
	    fi
    done
	systemctl daemon-reload
}

function install_k8s(){

    echo -e "\033[32mINFO: Copy hyperkube...\033[0m"
    cp hyperkube_${KUBE_VERSION} /usr/local/bin/hyperkube
	echo -e "\033[32mINFO: Create symbolic link...\033[0m"
    ln -sf /usr/local/bin/hyperkube /usr/local/bin/kubectl

	echo -e "\033[32mINFO: Copy kubernetes config...\033[0m"
    cp -r ${KUBE_CONF_DIR} ${KUBE_CONF_INSTALL_DIR}

	echo -e "\033[32mINFO: Copy kubernetes systemd config...\033[0m"
    cp ${KUBE_SYSTEMD_CONF_DIR}/*.service ${KUBE_SYSTEMD_CONF_INSTALL_DIR}
    systemctl daemon-reload

}


download_k8s
uninstall_k8s
install_k8s



 
