#!/bin/sh
docker rmi apache-doris-be:2.1.2

docker buildx b $(dirname $0) -t apache-doris-be:2.1.2