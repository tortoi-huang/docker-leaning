#!/usr/bin/env bash

set -e

dir=$(dirname $0)
sudo docker compose -f $dir/docker-compose.yml down -v

shopt -s dotglob

# 包含 .gitkeep 的文件和目录不删除，其他文件全部删除
sudo find $dir/data -mindepth 1 -type f ! -name '.gitkeep' -delete -print
sudo find $dir/data -mindepth 1 -type l -delete -print
sudo find $dir/data -mindepth 1 -type d -empty -delete -print

# find data -depth -mindepth 2 -maxdepth 2  ! -name '.gitkeep' -exec sudo rm -rf {} +