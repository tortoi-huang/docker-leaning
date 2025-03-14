#!/bin/sh

set -e

dir=$(dirname $0)
dir=$(readlink -f "$dir")

mkdir -p $dir/container/rootfs
CGO_ENABLED=0 go build -o $dir/container/rootfs/app $dir/app/main.go
echo "compiled go app"
