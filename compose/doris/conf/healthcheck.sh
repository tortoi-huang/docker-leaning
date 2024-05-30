#!/bin/bash

port_default=8080
host_default=localhost

port=${1:-$port_default}
host=${2:-$host_default}

exec 3<>/dev/tcp/${host}/${port}

# get the pre command result
if [ $? -eq 0 ]; then
    echo "$host:$port connect successful"
    exit 0
else
    echo "$host:$port connect fail"
    exit 1
fi
