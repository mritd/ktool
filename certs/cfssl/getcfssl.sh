#!/bin/bash

wget https://mritdftp.b0.upaiyun.com/cfssl/cfssl.tar.gz
tar -zxvf cfssl.tar.gz
mv cfssl cfssljson /usr/local/bin
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
rm -f cfssl.tar.gz
