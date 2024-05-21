#!/bin/sh

sudo docker compose down

dir=$(dirname $0)
sudo rm -rf $dir/data/be-01/log/*
sudo rm -rf $dir/data/be-01/script/*
sudo rm -rf $dir/data/be-01/storage/*

sudo rm -rf $dir/data/be-02/log/*
sudo rm -rf $dir/data/be-02/script/*
sudo rm -rf $dir/data/be-02/storage/*

sudo rm -rf $dir/data/be-03/log/*
sudo rm -rf $dir/data/be-03/script/*
sudo rm -rf $dir/data/be-03/storage/*

sudo rm -rf $dir/data/fe-01/log/*
sudo rm -rf $dir/data/fe-01/doris-meta/*

sudo rm -rf $dir/data/fe-02/log/*
sudo rm -rf $dir/data/fe-02/doris-meta/*

sudo rm -rf $dir/data/fe-03/log/*
sudo rm -rf $dir/data/fe-03/doris-meta/*