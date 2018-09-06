#!/bin/bash

set -e

wget https://mritdftp.b0.upaiyun.com/files/cfssl/cfssl.tar.gz
tar -zxvf cfssl.tar.gz
mv cfssl* /usr/bin
chmod +x /usr/bin/cfssl*
rm -f cfssl.tar.gz
