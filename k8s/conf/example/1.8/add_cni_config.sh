#!/bin/bash

sed -i 's@\(--cluster-dns.*\)@\1\n              --network-plugin=cni \\@gi' /etc/kubernetes/kubelet
systemctl daemon-reload
systemctl restart kubelet
