#!/bin/bash

set -e

dir=$(dirname $0)

mkdir -p $dir/data/controller0
mkdir -p $dir/data/controller1
mkdir -p $dir/data/controller2
mkdir -p $dir/data/broker0
mkdir -p $dir/data/broker1
mkdir -p $dir/data/broker2

docker compose -f $dir/docker-compose.yml up -d