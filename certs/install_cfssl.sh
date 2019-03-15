#!/bin/bash

set -e

wget https://oss.link/files/cfssl.tar.gz
tar -zxvf cfssl.tar.gz -C /usr/bin
rm -f cfssl.tar.gz
