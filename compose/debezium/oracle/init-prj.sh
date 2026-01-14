#!/usr/bin/env bash

dir=$(dirname $0)
wget -O ${dir}/lib/flink-sql-connector-oracle-cdc-3.5.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-oracle-cdc/3.5.0/flink-sql-connector-oracle-cdc-3.5.0.jar
wget -O ${dir}/lib/flink-sql-connector-postgres-cdc-3.5.0.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/3.5.0/flink-sql-connector-postgres-cdc-3.5.0.jar
wget -O ${dir}/lib/ojdbc8-23.26.0.0.0.jar https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/23.26.0.0.0/ojdbc8-23.26.0.0.0.jar
wget -O ${dir}/lib/kingbase8-9.0.1.jar https://repo1.maven.org/maven2/cn/com/kingbase/kingbase8/9.0.1/kingbase8-9.0.1.jar
