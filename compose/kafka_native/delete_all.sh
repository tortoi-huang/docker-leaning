#!/bin/bash

set -e

dir=$(dirname $0)
docker compose -f $dir/docker-compose.yml down

rm -rf $dir/data/controller0/*
rm -rf $dir/data/controller1/*
rm -rf $dir/data/controller2/*
rm -rf $dir/data/broker0/*
rm -rf $dir/data/broker1/*
rm -rf $dir/data/broker2/*
