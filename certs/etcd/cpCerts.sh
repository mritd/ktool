#!/bin/bash

rm -rf ../../etcd/conf/ssl
mkdir ../../etcd/conf/ssl
cp *.pem ../../etcd/conf/ssl
cp *.pem ../../calico/conf
