#!/bin/bash

docker compose down

dir=$(dirname $0)
rm -rf $dir/data/be-01/log
rm -rf $dir/data/be-01/script
rm -rf $dir/data/be-01/storage

rm -rf $dir/data/be-02/log
rm -rf $dir/data/be-02/script
rm -rf $dir/data/be-02/storage

rm -rf $dir/data/be-03/log
rm -rf $dir/data/be-03/script
rm -rf $dir/data/be-03/storage

rm -rf $dir/data/fe-01/log
rm -rf $dir/data/fe-01/doris-meta

rm -rf $dir/data/fe-02/log
rm -rf $dir/data/fe-02/doris-meta

rm -rf $dir/data/fe-03/log
rm -rf $dir/data/fe-03/doris-meta