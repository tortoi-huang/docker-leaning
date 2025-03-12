#!/bin/sh

set -e
dir=$(dirname $0)

sudo CNI_COMMAND=DEL CNI_CONTAINERID=test-app-ns CNI_NETNS=/var/run/netns/test-app-ns CNI_IFNAME=eth0 CNI_PATH=/opt/cni/bin \
    /opt/cni/bin/bridge < $dir/10-runc-cni.conf
sudo ip netns delete test-app-ns