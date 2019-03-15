#!/bin/bash

set -e

./deploy.sh -s -i 10.254.0.2 -d cluster.local -t coredns.yaml.sed > coredns.yaml
