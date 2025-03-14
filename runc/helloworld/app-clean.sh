#!/bin/sh

# set -e
dir=$(dirname $0)
dir=$(readlink -f "$dir")

rm $dir/container/rootfs/app
echo "deleted go app"