#!/bin/sh
docker rmi apache-doris:2.0.3-fe

docker buildx b $(dirname $0) -t apache-doris:2.0.3-fe