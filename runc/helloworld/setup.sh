#!/bin/sh

set -e
dir=$(dirname $0)

mkdir -p $dir/container/rootfs
CGO_ENABLED=0 go build -o $dir/container/rootfs/app $dir/app/main.go
echo "compiled go app"

ip netns add test-app-ns
echo "created network namespace"

CNI_COMMAND=ADD CNI_CONTAINERID=test-app-ns CNI_NETNS=/var/run/netns/test-app-ns CNI_IFNAME=eth0 CNI_PATH=/opt/cni/bin \
    /opt/cni/bin/bridge < $dir/container/10-runc-cni.conf

echo "created cni bridge network"

runc run -d -b $dir/container test-app
echo "created runc container"