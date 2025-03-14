#!/bin/sh

# set -e
dir=$(dirname $0)
dir=$(readlink -f "$dir")

runc kill test-app SIGTERM
runc delete test-app
echo "deleted runc container"

CNI_PATH=/opt/cni/bin cnitool del runc /var/run/netns/test-app-ns
sudo rm /etc/cni/net.d/10-runc-cni.conflist
echo "deleted cni bridge network"

ip netns delete test-app-ns
ip link delete runc0
rm -rf /var/lib/cni/networks/runc
echo "deleted network namespace"

# rm $dir/container/rootfs/app
# echo "deleted go app"