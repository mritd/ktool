#!/bin/bash

echo -e "\033[33mWARNING: Delete etcd!\033[0m"
rm -f /usr/local/bin/etcd /usr/local/bin/etcdctl

echo -e "\033[33mWARNING: Delete etcd config!\033[0m"
rm -rf /etc/etcd /var/lib/etcd

echo -e "\033[33mWARNING: Delete etcd systemd config!\033[0m"
if [ -z "/lib/systemd/system/etcd.service" ]; then
    systemctl stop etcd.service
    rm -f /lib/systemd/system/etcd.service
fi
systemctl daemon-reload
