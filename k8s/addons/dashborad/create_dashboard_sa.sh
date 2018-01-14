#!/bin/bash


if kubectl get sa dashboard-admin -n kube-system &> /dev/null;then
    echo -e "\033[33mWARNING: ServiceAccount dashboard-admin exist!\033[0m"
else
    kubectl create sa dashboard-admin -n kube-system
    kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
fi

kubectl describe secret -n kube-system $(kubectl get secrets -n kube-system | grep dashboard-admin | cut -f1 -d ' ') | grep -E '^token'
