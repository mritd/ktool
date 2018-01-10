#!/bin/bash

set -e

ETCD_DEFAULT_VERSION="3.2.12"

if [ "$1" != "" ]; then
  ETCD_VERSION=$1
else
  echo -e "\033[33mWARNING: ETCD_VERSION is blank,use default version: ${ETCD_DEFAULT_VERSION}\033[0m"
  ETCD_VERSION=${ETCD_DEFAULT_VERSION}
fi

function download(){
    if [ ! -f "etcd-v${ETCD_VERSION}-linux-amd64.tar.gz" ]; then
        wget https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
        tar -zxvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
    fi
}

function preinstall(){
	getent group etcd >/dev/null || groupadd -r etcd
	getent passwd etcd >/dev/null || useradd -r -g etcd -d /var/lib/etcd -s /sbin/nologin -c "etcd user" etcd
}

function install(){
    echo -e "\033[32mINFO: Copy etcd...\033[0m"
	tar -zxvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
	cp etcd-v${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin
	rm -rf etcd-v${ETCD_VERSION}-linux-amd64

    echo -e "\033[32mINFO: Copy etcd config...\033[0m"
    cp -r conf /etc/etcd
    chown -R etcd:etcd /etc/etcd
    chmod -R 755 /etc/etcd/ssl

    echo -e "\033[32mINFO: Copy etcd systemd config...\033[0m"
    cp systemd/*.service /lib/systemd/system
    systemctl daemon-reload
}

function postinstall(){
    if [ ! -d "/var/lib/etcd" ]; then
        mkdir /var/lib/etcd
        chown -R etcd:etcd /var/lib/etcd
    fi

}


download
preinstall
install
postinstall
