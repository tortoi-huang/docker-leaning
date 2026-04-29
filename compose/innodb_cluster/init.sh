#!/usr/bin/env bash
dir=$(dirname $0)

mkdir -p jdbc 

if [[ ! -f "${dir}/jdbc/mysql-connector-j-9.7.0.jar" ]]; then
  wget -O ${dir}/jdbc/mysql-connector-j-9.7.0.jar https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.7.0/mysql-connector-j-9.7.0.jar
fi
