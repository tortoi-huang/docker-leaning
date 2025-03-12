#!/bin/sh

# set -e
dir=$(dirname $0)

runc kill test-app SIGTERM
runc delete test-app
echo "deleted runc container"

CNI_COMMAND=DEL CNI_CONTAINERID=test-app-ns CNI_NETNS=/var/run/netns/test-app-ns CNI_IFNAME=eth0 CNI_PATH=/opt/cni/bin \
    /opt/cni/bin/bridge < $dir/container/10-runc-cni.conf
echo "deleted cni bridge network"

sudo ip netns delete test-app-ns
echo "deleted network namespace"

rm $dir/container/rootfs/app
echo "deleted go app"