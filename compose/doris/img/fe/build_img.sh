#!/bin/sh
sudo docker rmi apache-doris-fe:2.1.2

sudo docker buildx b $(dirname $0) -t apache-doris-fe:2.1.2