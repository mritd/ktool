#/!bin/bash

[ -d "/etc/etcd/ssl" ] && chmod -R 755 /etc/etcd/ssl
[ -d "/etc/etcd/ssl" ] && chown -R etcd:etcd /etc/etcd/ssl
[ -d "/var/lib/etcd" ] && chown -R etcd:etcd /var/lib/etcd
[ -d "/var/log/kube-audit" ] && chown -R kube:kube /var/log/kube-audit
[ -d "/var/lib/kubelet" ] && chown -R kube:kube /var/lib/kubelet
[ -d "/etc/kubernetes/ssl" ] && chown -R kube:kube /etc/kubernetes/ssl
