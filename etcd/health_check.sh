#!/bin/bash

etcdctl --ca-file /etc/etcd/ssl/etcd-root-ca.pem --key-file /etc/etcd/ssl/etcd-key.pem --cert-file /etc/etcd/ssl/etcd.pem cluster-health
