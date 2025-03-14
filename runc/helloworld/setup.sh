#!/bin/sh

set -e

dir=$(dirname $0)
dir=$(readlink -f "$dir")

# mkdir -p $dir/container/rootfs
# CGO_ENABLED=0 go build -o $dir/container/rootfs/app $dir/app/main.go
# echo "compiled go app"

ip netns add test-app-ns
echo "created network namespace"

# cp 10-runc-cni.conflist /etc/cni/net.d/
echo $dir/container/10-runc-cni.conflist
ln -s $dir/container/10-runc-cni.conflist /etc/cni/net.d/10-runc-cni.conflist
CNI_PATH=/opt/cni/bin cnitool add runc /var/run/netns/test-app-ns

echo "created cni bridge network"

runc run -d -b $dir/container test-app
echo "created runc container"