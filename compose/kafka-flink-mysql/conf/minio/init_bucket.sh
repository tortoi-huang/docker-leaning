#!/bin/bash

set -x;
mc config host add myminio http://minio:9000 ROOTNAME CHANGEME123;
mc admin user svcacct info myminio o4dCEAoZ776kFGh7QcbZ
if [ $? -eq 0 ]; then
    echo "access key aleady exists"
else
    mc admin user svcacct add myminio ROOTNAME --access-key "o4dCEAoZ776kFGh7QcbZ" --secret-key "MJdMWfCQnMk9cYex43WaJtXKVzupXfU2VnjjpNOe";
fi
mc ls myminio/flink
if [ $? -eq 0 ]; then
    echo "flink aleady exists"
    # mc rm -r --force myminio/flink;
else
    mc mb myminio/flink;
fi


