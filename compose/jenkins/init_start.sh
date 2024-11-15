#!/bin/bash

set -e

dir=$(dirname $0)

mkdir -p $dir/data/bitbucket
mkdir -p $dir/data/pg
mkdir -p $dir/data/jenkins

docker compose -f $dir/docker-compose.yml up -d