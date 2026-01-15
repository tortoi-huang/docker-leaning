#!/usr/bin/env bash

dir=$(dirname $0)
mkdir -p $dir/data/oradata
chmod 777 $dir/data/oradata
mkdir -p $dir/data/kingbase
chmod 777 $dir/data/kingbase

if [[ ! -f "${dir}/lib/flink-sql-connector-oracle-cdc-3.5.0.jar" ]]; then
  wget -O ${dir}/lib/flink-sql-connector-oracle-cdc-3.5.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-oracle-cdc/3.5.0/flink-sql-connector-oracle-cdc-3.5.0.jar
fi

if [[ ! -f "${dir}/lib/flink-sql-connector-postgres-cdc-3.5.0.jar" ]]; then
  wget -O ${dir}/lib/flink-sql-connector-postgres-cdc-3.5.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/3.5.0/flink-sql-connector-postgres-cdc-3.5.0.jar
fi

if [[ ! -f "${dir}/lib/ojdbc8-23.26.0.0.0.jar" ]]; then
  wget -O ${dir}/lib/ojdbc8-23.26.0.0.0.jar https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/23.26.0.0.0/ojdbc8-23.26.0.0.0.jar
fi

if [[ ! -f "${dir}/lib/kingbase8-9.0.1.jar" ]]; then
  wget -O ${dir}/lib/kingbase8-9.0.1.jar https://repo1.maven.org/maven2/cn/com/kingbase/kingbase8/9.0.1/kingbase8-9.0.1.jar
fi

if [[ ! -f "${dir}/lib/postgresql-42.6.2.jar" ]]; then
  wget -O ${dir}/lib/postgresql-42.6.2.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.2/postgresql-42.6.2.jar
fi

if [[ ! -f "${dir}/lib/flink-connector-jdbc-3.3.0-1.20.jar" ]]; then
  wget -O ${dir}/lib/flink-connector-jdbc-3.3.0-1.20.jar https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.3.0-1.20/flink-connector-jdbc-3.3.0-1.20.jar
fi
