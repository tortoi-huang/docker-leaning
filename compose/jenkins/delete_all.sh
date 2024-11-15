#!/bin/bash
set -e

dir=$(dirname $0)
echo "stopping container and removing volumn ..."
docker compose -f $dir/docker-compose.yml down -v

echo "deleting bitbucket data ..."
rm -rf $dir/data/bitbucket/*
echo "deleting postgres data ..."
rm -rf $dir/data/pg/*
echo "deleting jenkins data ..."
rm -rf $dir/data/jenkins/*
echo "all data were deleted"
