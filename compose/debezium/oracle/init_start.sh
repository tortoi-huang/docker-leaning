#!/usr/bin/env bash

set -x
set -euo pipefail

dir=$(dirname $0)
mkdir -p $dir/data/oradata
mkdir -p $dir/data/kingbase
sudo docker compose -f $dir/docker-compose.yml up -d
