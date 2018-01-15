#!/bin/bash

KUBE_VERSION=${1:-"1.8.6"}

if [ ! -f "k8s_images_v${KUBE_VERSION}.tar.gz" ]; then
    wget https://mritdftp.b0.upaiyun.com/files/kubernetes/k8s_images_v${KUBE_VERSION}.tar.gz
fi

tar -zxvf k8s_images_v${KUBE_VERSION}.tar.gz > images

for imageName in `cat images`; do
    docker load < ${imageName}
    rm -f ${imageName}
done

rm -f images
