#!/bin/bash

set -e

systemctl stop nginx-proxy

rm -rf /etc/nginx
rm -f /lib/systemd/system/nginx-proxy.service

systemctl daemon-reload
