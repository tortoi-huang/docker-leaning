#!/bin/sh
docker rmi apache-doris:2.1.2-be

docker buildx b $(dirname $0) -t apache-doris:2.1.2-be