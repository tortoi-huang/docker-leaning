#!/bin/sh
docker rmi apache-doris-fe:2.1.2

docker buildx b $(dirname $0) -t apache-doris-fe:2.1.2