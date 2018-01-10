#!/bin/bash

set -e

mkdir /etc/nginx

cp nginx.conf /etc/nginx
cp nginx-proxy.service /lib/systemd/system

systemctl daemon-reload
systemctl enable nginx-proxy
systemctl start nginx-proxy
