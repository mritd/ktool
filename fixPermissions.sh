#/!bin/bash

chmod -R 755 /etc/etcd/ssl
chown -R etcd:etcd /etc/etcd/ssl
chown -R etcd:etcd /var/lib/etcd
chown -R kube:kube /var/log/kube-audit
chown -R kube:kube /etc/kubernetes/ssl
