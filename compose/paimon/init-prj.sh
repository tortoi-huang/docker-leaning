#!/usr/bin/env bash

dir=$(dirname $0)

mkdir -p $dir/data/minio
mkdir -p $dir/data/flink/checkpoints
mkdir -p $dir/data/flink/savepoints
mkdir -p $dir/data/flink/ha
mkdir -p $dir/data/pg
mkdir -p $dir/data/zookeeper/node1/logs
mkdir -p $dir/data/zookeeper/node1/data
mkdir -p $dir/data/zookeeper/node1/datalog
mkdir -p $dir/data/zookeeper/node2/logs
mkdir -p $dir/data/zookeeper/node2/data
mkdir -p $dir/data/zookeeper/node2/datalog
mkdir -p $dir/data/zookeeper/node3/logs
mkdir -p $dir/data/zookeeper/node3/data
mkdir -p $dir/data/zookeeper/node3/datalog

chmod -R 777 $dir/data

if [[ ! -f "${dir}/lib/flink-sql-connector-postgres-cdc-3.5.0.jar" ]]; then
  wget -O ${dir}/lib/flink-sql-connector-postgres-cdc-3.5.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/3.5.0/flink-sql-connector-postgres-cdc-3.5.0.jar
fi

if [[ ! -f "${dir}/lib/postgresql-42.6.2.jar" ]]; then
  wget -O ${dir}/lib/postgresql-42.6.2.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.2/postgresql-42.6.2.jar
fi

if [[ ! -f "${dir}/lib/flink-connector-jdbc-3.3.0-1.20.jar" ]]; then
  wget -O ${dir}/lib/flink-connector-jdbc-3.3.0-1.20.jar https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.3.0-1.20/flink-connector-jdbc-3.3.0-1.20.jar
fi

if [[ ! -f "${dir}/lib/paimon-bundle-1.3.1.jar" ]]; then
  wget -O ${dir}/lib/paimon-bundle-1.3.1.jar https://repo1.maven.org/maven2/org/apache/paimon/paimon-bundle/1.3.1/paimon-bundle-1.3.1.jar
fi

if [[ ! -f "${dir}/lib/flink-s3-fs-hadoop-1.20.3.jar" ]]; then
  wget -O ${dir}/lib/flink-s3-fs-hadoop-1.20.3.jar https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.20.3/flink-s3-fs-hadoop-1.20.3.jar
fi

if [[ ! -f "${dir}/lib/paimon-flink-1.20-1.3.1.jar" ]]; then
  wget -O ${dir}/lib/paimon-flink-1.20-1.3.1.jar https://repo1.maven.org/maven2/org/apache/paimon/paimon-flink-1.20/1.3.1/paimon-flink-1.20-1.3.1.jar
fi

if [[ ! -f "${dir}/lib/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar" ]]; then
  wget -O ${dir}/lib/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-10.0/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar
fi

if [[ ! -f "${dir}/lib/paimon-s3-1.3.1.jar" ]]; then
  wget -O ${dir}/lib/paimon-s3-1.3.1.jar https://repo1.maven.org/maven2/org/apache/paimon/paimon-s3/1.3.1/paimon-s3-1.3.1.jar
fi
